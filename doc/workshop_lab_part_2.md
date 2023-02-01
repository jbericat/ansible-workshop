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
      - [3.2. Running the playbook with ansible-navigator on DEV](#32-running-the-playbook-with-ansible-navigator-on-dev)
      - [3.3. Running the playbook with ansible-navigator on STAGING](#33-running-the-playbook-with-ansible-navigator-on-staging)
      - [3.4. Summing-up: Pros and cons of this ansible automation method](#34-summing-up-pros-and-cons-of-this-ansible-automation-method)
      - [3.5. Documentation references](#35-documentation-references)
    - [4. Encrypting sensitive data with ansible Vault](#4-encrypting-sensitive-data-with-ansible-vault)
      - [4.1. Encrypt the var file with the F5 password](#41-encrypt-the-var-file-with-the-f5-password)
      - [4.2. Store the **DEV ENVIRONMENT** vault password in an environment variable](#42-store-the-dev-environment-vault-password-in-an-environment-variable)
      - [4.3. Run the playbook on the **DEV ENVIRONMENT**](#43-run-the-playbook-on-the-dev-environment)
      - [4.4. Summing-up: Pros and cons of this ansible automation method](#44-summing-up-pros-and-cons-of-this-ansible-automation-method)
      - [4.5. Documentation references](#45-documentation-references)
    - [5. Installing AWX for DEV \& STAGING environments](#5-installing-awx-for-dev--staging-environments)
    - [6A. Create AWX / Tower objects using AWX GUI](#6a-create-awx--tower-objects-using-awx-gui)
    - [6B. Create AWX / Tower objects using Ansible galaxy awx.awx collection (CaC)](#6b-create-awx--tower-objects-using-ansible-galaxy-awxawx-collection-cac)
    - [7. Conclusion (Real use case) - Run a Playbook Using EE's and vault on AWX / Tower](#7-conclusion-real-use-case---run-a-playbook-using-ees-and-vault-on-awx--tower)


## Introduction

Run a playbook using an ansible-galaxy collection module via REST API.......................

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
echo 'export PATH=HOME/.local/bin:PATH' >> ~/.profile
source ~/.profile
```

#### 3.2. Running the playbook with ansible-navigator on DEV

```bash
ansible-navigator --eei quay.io/jordi_bericat/awx-ee:2.13-latest \
 run workshop_lab_part_2.yml \
 -i environments/dev/ \
 -e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
 -l f5bigip
```

#### 3.3. Running the playbook with ansible-navigator on STAGING

```bash
ansible-navigator --eei quay.io/jordi_bericat/awx-ee:2.13-latest \
 run workshop_lab_part_2.yml \
 -i environments/staging/ \
 -e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
 -l f5bigip
```

#### 3.4. Summing-up: Pros and cons of this ansible automation method

**PROS:**

- Full automation (no need neither of specifyng SSH password on runtime nor of creating / setting SSH keys)
- Total portability and scalability of the environment (we can use the same EE container in all envs, even in vscode for debugging and coding purposes!)

**CONS:**

- Poor security measures (the F5 devices' password is stored in plaintext on the group vars)
- Still not very user friendly

#### 3.5. Documentation references

https://ansible-navigator.readthedocs.io/en/latest/faq/

### 4. Encrypting sensitive data with ansible Vault

#### 4.1. Encrypt the var file with the F5 password

```bash
ansible-vault encrypt environments/dev/.vault/f5bigip.yml
```

We can also encrypt the password string directly so we won't have to include
the vaulted vars file (that's useful when using different inventory files)

```bash
ansible-vault encrypt_string --show-input - 
```

#### 4.2. Store the **DEV ENVIRONMENT** vault password in an environment variable

```bash
mkdir ~/.vault/
touch ~/.vault/.dev_vault_password
chmod 600 ~/.dev_vault_password
 echo 123456 > ~/.dev_vault_password
```

#### 4.3. Run the playbook on the **DEV ENVIRONMENT**

ansible-navigator --eei quay.io/jordi_bericat/awx-ee:2.13-latest \
run workshop_lab_part_2.yml \
-i environments/dev/ \
-e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
-l f5bigip \
--vault-password-file ~/.vault_password

 #### 4.4. Summing-up: Pros and cons of this ansible automation method

**PROS:**

**CONS:**

#### 4.5. Documentation references

- https://docs.ansible.com/ansible/latest/cli/ansible-vault.html
- https://ansible-navigator.readthedocs.io/en/latest/faq/#how-can-i-use-a-vault-password-with-ansible-navigator

### 5. Installing AWX for DEV & STAGING environments

- install minikube
- install AWX

### 6A. Create AWX / Tower objects using AWX GUI

1. Add Execution Environment
2. Create Project
3. Add Vault Credential
4. Create Inventory -> Add group vars
5. Add Hosts
6. Create Template Job -> Create Survey
7. Run Playbook

### 6B. Create AWX / Tower objects using Ansible galaxy awx.awx collection (CaC)

TBD



### 7. Conclusion (Real use case) - Run a Playbook Using EE's and vault on AWX / Tower

AWX on DEV & STAGING (using EE and vault)
