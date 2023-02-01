# Ansible Workshop part 2: Automation deployment with Ansible

## Table of Contents

- [Ansible Workshop part 2: Automation deployment with Ansible](#ansible-workshop-part-2-automation-deployment-with-ansible)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Activities](#activities)
    - [1. Create an Ansible EE for further use on this lab](#1-create-an-ansible-ee-for-further-use-on-this-lab)
    - [2. Deploy the EE on vscode](#2-deploy-the-ee-on-vscode)
    - [3. Run a playbook using EE's instead of python venv's via TUI (ansible-navigator)](#3-run-a-playbook-using-ees-instead-of-python-venvs-via-tui-ansible-navigator)
      - [3.1. Install ansible-navigator](#31-install-ansible-navigator)
      - [3.2. Create the project structure and populate the inventory](#32-create-the-project-structure-and-populate-the-inventory)
        - [3.2.1. Project structure](#321-project-structure)
        - [3.2.2. Populate the inventory](#322-populate-the-inventory)
      - [3.3. Create the playbook](#33-create-the-playbook)
      - [3.4. Running the playbook with ansible-navigator on DEV](#34-running-the-playbook-with-ansible-navigator-on-dev)
      - [3.5. Running the playbook with ansible-navigator on STAGING](#35-running-the-playbook-with-ansible-navigator-on-staging)
      - [3.6. Summing-up: Pros and cons of this ansible automation method](#36-summing-up-pros-and-cons-of-this-ansible-automation-method)
      - [3.7. Documentation references](#37-documentation-references)
    - [4. Encrypting sensitive data with ansible Vault](#4-encrypting-sensitive-data-with-ansible-vault)
      - [4.1. Encrypt the var file with the F5 password](#41-encrypt-the-var-file-with-the-f5-password)
      - [4.2. Store the **DEV ENVIRONMENT** vault password in protected file](#42-store-the-dev-environment-vault-password-in-protected-file)
      - [4.3. Run the playbook on the **DEV ENVIRONMENT**](#43-run-the-playbook-on-the-dev-environment)
      - [4.4. Summing-up: Pros and cons of this ansible automation method](#44-summing-up-pros-and-cons-of-this-ansible-automation-method)
      - [4.5. Documentation references](#45-documentation-references)
    - [5. Installing AWX for DEV \& STAGING environments](#5-installing-awx-for-dev--staging-environments)
- [AWX Installation on a KVM Hypervisor (NodePort Version)](#awx-installation-on-a-kvm-hypervisor-nodeport-version)
  - [5.1. Dependencies](#51-dependencies)
    - [5.1.1. Set-up the linux host to route traffic to the AWX Pod, so we can access the other hosts on the LAB](#511-set-up-the-linux-host-to-route-traffic-to-the-awx-pod-so-we-can-access-the-other-hosts-on-the-lab)
    - [5.1.2. QEMU Config](#512-qemu-config)
  - [5.2. Minikube Installation procedure](#52-minikube-installation-procedure)
  - [5.3. Follow the steps here to install Minikube](#53-follow-the-steps-here-to-install-minikube)
  - [5.4. AWX Installation procedure (https://asciinema.org/a/416946)](#54-awx-installation-procedure-httpsasciinemaorga416946)
  - [5.5. AWX Installation](#55-awx-installation)
    - [5.5.1. Deploy AWX Service (NGINX Ingress Controller Method)](#551-deploy-awx-service-nginx-ingress-controller-method)
    - [5.5.2. Admin password administration](#552-admin-password-administration)
      - [5.5.2.1. Get the default awx admin password](#5521-get-the-default-awx-admin-password)
      - [5.5.2.2. Change awx admin password](#5522-change-awx-admin-password)
      - [5.5.2.3. Add awx super-user](#5523-add-awx-super-user)
    - [6.1. Create AWX / Tower objects](#61-create-awx--tower-objects)
      - [6.1.1. using AWX GUI](#611-using-awx-gui)
    - [6.1.2. Using Ansible galaxy awx.awx collection (CaC)](#612-using-ansible-galaxy-awxawx-collection-cac)
    - [6.2. Run a Playbook Using EE's and vault on AWX / Tower](#62-run-a-playbook-using-ees-and-vault-on-awx--tower)
    - [6.3. Documentation references](#63-documentation-references)


## Introduction

Om this second part of the demonstration lab we'll be running a playbook using 
an ansible-galaxy collection module via REST API. For that, instead of 
installing the collection locally on the Ansible Control Node, we are going to 
create an Execution Environment, where we will embed all the modules 
dependencies. This way we can use the same EE on diferents scenarios and 
environments. To see the benefits of using the EE, instead of running the PB 
via CLI, we're going first to use the ansible-navigator TUI tool. Afterwards,
we'll run the same PB on AWX, where the same EE will be deployed.

| **Playbook** | **Description** |
|-|-|
| [workshop_lab_part_2.yml](workshop_lab_part_2.yml) | Ansible playbook that gathers all the F5-BIGIP Balanced Services (that is, virtual servers and pools) on a specific month via REST |

## Activities

### 1. Create an Ansible EE for further use on this lab

```bash
#!/bin/bash

# 1) Installing ansible-builder

pip install ansible-builder

# 2) Defining the Execution Environment

# 2.1) Creating context files structure

rm -rf ~/ansible-builder
mkdir ~/ansible-builder && cd ~/ansible-builder
touch execution-environment.yml requirements.yml requirements.txt bindep.txt 
mkdir context && cd context
touch run.sh && chmod 774 run.sh
cat << EOF > run.sh
#!/bin/bash
ansible-runner worker --private-data-dir=/runner
EOF

# 2.2) Setting Execution Environment global definitions

cd ~/ansible-builder
cat << EOF > execution-environment.yml
---
version: 1

build_arg_defaults:
  EE_BASE_IMAGE: 'quay.io/ansible/ansible-runner:latest'

dependencies:
  galaxy: requirements.yml
  python: requirements.txt
  system: bindep.txt

additional_build_steps:
  append:
    - RUN alternatives --set python /usr/bin/python3
    - COPY --from=quay.io/project-receptor/receptor:latest /usr/bin/receptor /usr/bin/receptor
    - RUN mkdir -p /var/run/receptor
    - ADD run.sh /run.sh
    - CMD /run.sh
    - USER 1000 
    - RUN git lfs install
...
EOF

# 2.3) Setting Galaxy Collections

cat << EOF > requirements.yml
---
collections:
  - name: community.general
  - name: awx.awx
    version: 21.8.0
  - name: f5networks.f5_modules
    version: 1.16.0
...
EOF

# 2.4) Setting Python pip packages

cat << EOF > requirements.txt
urllib3
ansible-lint==6.11.0
pyvmomi==7.0.3
pyvim==3.0.3
EOF

# 2.5) Setting OS Dependencies

cat << EOF > bindep.txt
python38-devel [platform:centos]
subversion [platform:centos]
git-lfs [platform:centos]
EOF

# 3) Running ansible-builder to create the EE

# 3.1) Creating python venv

cd ~/ansible-builder
python3 -m venv builder_venv
source builder_venv/bin/activate

# 3.2) Creating the EE docker container
ansible-builder build --tag quay.io/jordi_bericat/awx-ee:2.13-workshop --context ./context --container-runtime docker  --verbosity 3

# 3.3) Uploading the EE Container to the quay registry

docker login quay.io
docker push quay.io/jordi_bericat/awx-ee:2.13-workshop
deactivate builder_venv
```

### 2. Deploy the EE on vscode

```
Ctrl+, -> Remote [WSL: Ubuntu 20.04] -> Ansible -> "ansible.executionEnvironment.image": "quay.io/jordi_bericat/awx-ee:2.13-latest"
```

### 3. Run a playbook using EE's instead of python venv's via TUI (ansible-navigator)

#### 3.1. Install ansible-navigator

```bash
python3 -m pip install ansible-navigator --user
cp ~/.profile ~/.profile.bak
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.profile
source ~/.profile
```
#### 3.2. Create the project structure and populate the inventory

##### 3.2.1. Project structure

```bash
#!/bin/bash

# Init project structure

mkdir \
 environments/ \
 environments/dev \
 environments/dev/.vault \
 environments/dev/group_vars \
 environments/dev/host_vars \
 environments/staging \
 environments/staging/.vault \
 environments/staging/group_vars \
 environments/staging/host_vars \
 environments/prod \
 environments/prod/.vault \
 environments/prod/group_vars \
 environments/prod/host_vars \
 logs

touch \
 .gitignore \
 environments/dev/hosts \
 environments/dev/group_vars/f5bigip.yml \
 environments/staging/hosts \
 environments/prod/hosts \
 workshop_lab_part_2.yml

echo *_venv > .gitignore
```

##### 3.2.2. Populate the inventory

```bash
#!/bin/bash

# DEVELOPMENT
cat << EOF > environments/dev/hosts
[f5bigip]
f5bigip[01:03].dev.cgr-lab.lan
EOF

cat << EOF > environments/dev/group_vars/f5-bigip.yml
f5_provider:
  user: "admin"
  password: "CGR123ABANCA"
  server: "{{ inventory_hostname }}"
  server_port: 443
  validate_certs: no
  transport: rest
EOF

# STAGING
cat << EOF > environments/staging/hosts
[f5bigip]
f5bigip[01:03].staging.cgr-lab.lan
EOF

# PRODUCTION
cat << EOF > environments/prod/hosts
[f5bigip]
f5bigip[01:03].prod.cgr-lab.lan
EOF
```

#### 3.3. Create the playbook

```yaml
---
- name: >
    PLAYBOOK - "workshop_lab_part_2.yml" (F5-BIGIP Automation via REST
    on multiple environments using Ansible inventory files)
  hosts: all
  vars_files:
    - "{{ playbook_dir + vault_file }}"
  gather_facts: no
  tasks:

  - name: >
      1. Gathering all the balanced services created for the
      [{{ inventory_hostname }}] F5-BIGIP device from the
      [{{ inventory_file|regex_replace(playbook_dir,'') }}] inventory
      via REST
    f5networks.f5_modules.bigip_command:
      provider: "{{ f5_provider }}"
      commands: > 
        list ltm virtual creation-time description |
        grep -A 1 '{{ date_stats }}' |
        grep '{{ automation_id }}' -c
    register: results
    delegate_to: localhost
    ignore_errors: true

  - name: 2. SHOW RESULTS
    debug:
      msg: >
        total balanced services created on [{{ date_stats }}] =
        [{{ results.stdout|default(none) }}]
...

```

#### 3.4. Running the playbook with ansible-navigator on DEV

**FOR THIS ACTIVITY MAKE SURE THE F5-PASSWORD IS STORED IN PLAIN-TEXT ON THE GROUP-VARS FILE FOR THE DEV ENVIRONMENT!**

```bash
ansible-navigator --eei quay.io/jordi_bericat/awx-ee:2.13-latest \
 run workshop_lab_part_2.yml \
 -i environments/dev/ \
 -e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
 -l f5bigip \
 --lf logs/ansible-navigator.log
```

#### 3.5. Running the playbook with ansible-navigator on STAGING

```bash
ansible-navigator --eei quay.io/jordi_bericat/awx-ee:2.13-latest \
 run workshop_lab_part_2.yml \
 -i environments/staging/ \
 -e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
 -l f5bigip
```

#### 3.6. Summing-up: Pros and cons of this ansible automation method

**PROS:**

- Full automation (no need neither of specifyng SSH password on runtime nor of creating / setting SSH keys)
- Total portability and scalability of the environment (we can use the same EE container in all envs, even in vscode for debugging and coding purposes!)

**CONS:**

- Poor security measures (the F5 devices' password is stored in plaintext on the group vars)
- Still not totally user friendly

#### 3.7. Documentation references

https://ansible-navigator.readthedocs.io/en/latest/faq/

### 4. Encrypting sensitive data with ansible Vault

#### 4.1. Encrypt the var file with the F5 password

We can encrypt a variable file using the ansible-vault command, like this: 

```bash
ansible-vault encrypt environments/dev/.vault/f5bigip.yml
```

We can also encrypt the password string directly so we won't have to include
the vaulted vars file (that's useful when using different inventory files)

```bash
ansible-vault encrypt_string --show-input - 
```

For this activity we'll just add the encrypted string to the 
`group_vars/f5bigip.yml` file:

```bash
cat << EOF > environments/dev/group_vars/f5bigip.yml
f5_provider:
  user: "admin"
  password: !vault |
    $ANSIBLE_VAULT;1.1;AES256
    66323737623639653633356434323964636130623061333730393731353533366232633163353632
    6161356235393637313537313832343565633366656261610a303035623436383165646431363337
    36623337313037346332336563663162656363336165376165623534326264303133326139313939
    3733636434646339360a323463396531376533643231323561363231633233646265636336666537
    6537
  server: "{{ inventory_hostname }}"
  server_port: 443
  validate_certs: no
  transport: rest
EOF
```

#### 4.2. Store the **DEV ENVIRONMENT** vault password in protected file

```bash
mkdir ~/.vault/
touch ~/.vault/.dev_vault_password
chmod 600 ~/.vault/.dev_vault_password
 echo 123456 > ~/.vault/.dev_vault_password
```

#### 4.3. Run the playbook on the **DEV ENVIRONMENT**

```bash
ansible-navigator --eei quay.io/jordi_bericat/awx-ee:2.13-latest \
run workshop_lab_part_2.yml \
-i environments/dev/ \
-e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
-l f5bigip \
--lf logs/ansible-navigator.log \
--vault-password-file ~/.vault/.dev_vault_password
```

 #### 4.4. Summing-up: Pros and cons of this ansible automation method

**PROS:**

- Full automation (no need neither of specifyng SSH password on runtime nor of creating / setting SSH keys)
- Total portability and scalability of the environment (we can use the same EE container in all envs, even in vscode for debugging and coding purposes)
- Better security measures: the F5 devices' password is stored on an encrypted var string. We also store the vault password in a protected file on the Ansible Control Node filesystem

**CONS:**

- Still not totally user friendly

#### 4.5. Documentation references

- https://docs.ansible.com/ansible/latest/cli/ansible-vault.html
- https://docs.ansible.com/ansible/latest/vault_guide/index.html
- https://ansible-navigator.readthedocs.io/en/latest/faq/#how-can-i-use-a-vault-password-with-ansible-navigator

### 5. Installing AWX for DEV & STAGING environments

# AWX Installation on a KVM Hypervisor (NodePort Version)

## 5.1. Dependencies

### 5.1.1. Set-up the linux host to route traffic to the AWX Pod, so we can access the other hosts on the LAB

```bash
sudo sysctl -w net.ipv4.ip_forward=1

# To make it persistent:

# 1. you need to enable IP forwarding in the configuration file, usually stored at /etc/sysctl.conf:
# 2. Find and uncomment the net.ipv4.ip_forward=1 line:
# 3. Save the changes and exit the file.
```

### 5.1.2. QEMU Config

To deploy the Minikube cluster on a KVM Hypervisor we need to use the **cpu-passthrough** arg in QEMU when creating the VM:

```-machine type=pc,accel=kvm -vga virtio -usbdevice tablet -boot order=cd -cpu host```

To be cool, we need a VM with at least: 4vCPU, 6Gb RAM, 200Gb (if we want to create diferent AWX instances)

## 5.2. Minikube Installation procedure

First we install the kubectl CLI

```bash
cd ~/Downloads
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --output=yaml
```

## 5.3. Follow the steps here to install Minikube

[https://minikube.sigs.k8s.io/docs/](https://minikube.sigs.k8s.io/docs/)

```bash
sudo apt-get install -y containerd docker.io 
sudo usermod -aG docker $USER && newgrp docker
cd ~/Downloads
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
minikube start --cpus=6 --memory=6g --addons=ingress,dashboard,metrics-server
kubectl get pods -A

sudo touch /etc/systemd/system/minikube.service
sudo chmod +x /etc/systemd/system/minikube.service
sudo vim /etc/systemd/system/minikube.service

------ ADD THIS TO minikube.service --------
[Unit]
Description=minikube
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
User=user
RemainAfterExit=yes
WorkingDirectory=/home/user
ExecStart=/usr/local/bin/minikube start --cpus=6 --memory=6g addons=ingress,dashboard,metrics-server
ExecStop=/usr/local/bin/minikube stop

[Install]
WantedBy=multi-user.target
---------------------------------------------

sudo systemctl enable minikube.service

# REBOOT AND CHECK SERVICE STATUS:

sudo systemctl status minikube.service
minikube status
minikube dashboard &
```

## 5.4. AWX Installation procedure (<https://asciinema.org/a/416946>)

 select the AWX Operator version and deploy the Kubernetes cluster with the AWX instance:

[https://github.com/ansible/awx-operator](https://github.com/ansible/awx-operator)

```bash

# INSTALL kustomize https://kubectl.docs.kubernetes.io/installation/kustomize/

cd ~/Downloads
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

# SOMETIMES THIS IMAGE CANNOT BE PULLED TO THE CONTAINER BY MINIKUBE, WE DO IT MANUALLY

minikube image load "quay.io/ansible/awx-ee:latest" 

vim ~/Downloads/kustomization.yaml

------------ADD THIS TO ~/kustomization.yaml -----------
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  # Find the latest tag here: https://github.com/ansible/awx-operator/releases
  - github.com/ansible/awx-operator/config/default?ref=<tag>

# Set the image tags to match the git version from above
images:
  - name: quay.io/ansible/awx-operator
    newTag: <tag>

# Specify a custom namespace in which to install AWX
namespace: <id-namespace>
-------------------------------------------------------

cd ~/Downloads
./kustomize build . | kubectl apply -f -
kubectl config set-context --current --namespace=<id-namespace>
kubectl get pods
```

## 5.5. AWX Installation

### 5.5.1. Deploy AWX Service (NGINX Ingress Controller Method)

```bash
vim awx-nginx-ingress.yml
```

```yaml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx-nginx-ingress
spec:
  service_type: clusterip
  ingress_type: ingress
  hostname: awx.staging.cgr-lab.lan
```

```bash
kubectl apply -f awx-nginx-ingress.yml
kubectl get awx
kubectl get pods -l "app.kubernetes.io/managed-by=awx-operator" -w
kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator"  
minikube service list
kubectl get ingresses
```

### 5.5.2. Admin password administration

#### 5.5.2.1. Get the default awx admin password

```bash
kubectl get secret awx-nginx-ingress-admin-password -o jsonpath="{.data.password}" | base64 --decode
```

#### 5.5.2.2. Change awx admin password

```bash
# Get pods and its containers to retrieve container name:

kubectl get pods -n awx -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{"\t"}{.metadata.namespace}{"\t"}{range .spec.containers[*]}{.name}{"=>"}{.image}{","}{end}{end}'|sort|column -t

minikube kubectl exec pod/awx-nginx-5456cdb7b6-b765v -- --container awx-nginx-web -it awx-manage changepassword admin
```

#### 5.5.2.3. Add awx super-user

```bash
minikube kubectl exec pod/awx-21-4-0-59446fbc85-l87hn -- --container awx-21-4-0-web -it awx-manage createsuperuser
```

### 6.1. Create AWX / Tower objects

#### 6.1.1. using AWX GUI

1. Add Execution Environment -> quay.io/jordi_bericat/awx-ee:2.13-workshop
2. Create Project
3. Add Vault Credential
4. Create Inventory (DEV) -> Add group vars
5. Add Hosts -> f5bigip01.dev.cgr-lab.lan / f5bigip02.dev.cgr-lab.lan / f5bigip03.dev.cgr-lab.lan
6. Create Template Job -> Create Survey
7. Run Playbook

### 6.1.2. Using Ansible galaxy awx.awx collection (CaC)

One of the greatest features of the Automation Controller is that we can
interact with the via CaC to create any of its objects, like Template jobs,
Projects, Credentials, and so forth. To do so, we can use two different 
Ansible modules collections available on Ansible Galaxy:

- For the upstream version of the controller (that is, AWX), we use the the `awx.awx` collection
- For the downstream version of the controller (that is, the Automation Controller), we use the the `redhat_cop.controller_configuration` collection

However, in this demostration lab we won't get that far, so we'll stick to the
GUI method. On the [6.3 section](#6.3._Documentation_references) you'll find
furthe references about configuring the Automation Controller / AWX by means of
CaC

### 6.2. Run a Playbook Using EE's and vault on AWX / Tower

Running the Template Job on AWX

**PROS:**

- Full automation (no need neither of specifyng SSH password on runtime nor of creating / setting SSH keys)
- Total portability and scalability of the environment (we can use the same EE container in all envs, even in vscode for debugging and coding purposes)
- Better security measures: the F5 devices' password is stored on an encrypted var string. We also store the vault password in a protected file on the Ansible Control Node filesystem
- Very user friendly interface

**CONS:**

- Method not suited for coding and debugging (for that is ansible-navigator is less time consuming, since we don't have to sync the project every time we run a playbook to see what it does)

### 6.3. Documentation references

- https://github.com/ansible/awx
- https://docs.ansible.com/ansible-tower/index.html
- https://docs.ansible.com/ansible/latest/collections/awx/awx/index.html
- https://docs.ansible.com/ansible-tower/latest/html/towercli/index.html
