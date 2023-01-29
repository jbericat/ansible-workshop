# Ansible Workshop part 2: Automation deployment with Ansible

## Table of Contents

- [Ansible Workshop part 2: Automation deployment with Ansible](#ansible-workshop-part-2-automation-deployment-with-ansible)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Activities](#activities)
    - [1. Create an Ansible EE for this use case](#1-create-an-ansible-ee-for-this-use-case)
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
    - [6. Create AWX / Tower objects using Ansible galaxy collections (CaC)](#6-create-awx--tower-objects-using-ansible-galaxy-collections-cac)
    - [7. Conclusion (Real use case) - Run a Playbook Using EE's and vault on AWX / Tower](#7-conclusion-real-use-case---run-a-playbook-using-ees-and-vault-on-awx--tower)


## Introduction

Run a playbook using an ansible-galaxy collection module via REST API.......................

| **Playbook** | **Description** |
|-|-|
| [workshop_lab_part_2.yml](workshop_lab_part_2.yml) | Ansible playbook that gathers all the F5-BIGIP Balanced Services (that is, virtual servers and pools) on a specific month via REST |

## Activities

### 1. Create an Ansible EE for this use case

1) Deactivate venv

2) Setup and run ansible-builder

```bash
#!/bin/bash
# https://www.linkedin.com/pulse/creating-custom-ee-awx-phil-griffiths/

# INSTRUCTIONS

# 1A. On Windows: Start Docker Desktop, which will be available in WSL too
# 1B. On Linux: Make sure the docker service is running
# 2. Setup ansible-builer files: bindep.txt / execution-environment.yaml / requirements.txt / requirements.yml
# 3. Run this script -> source build_AWX_EE.sh

rm -rf ~/ansible-builder
cp -rp ansible-builder ~/ansible-builder && cd ~/ansible-builder
python3 -m venv builder
source builder/bin/activate
pip install ansible
pip install ansible-builder
# pip install ansible-builder==1.0.0.0a1
ansible-builder build --tag quay.io/jordi_bericat/awx-ee:2.13-latest --context ./context --container-runtime docker
docker login quay.io
docker push quay.io/jordi_bericat/awx-ee:2.13-latest
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

### 6. Create AWX / Tower objects using Ansible galaxy collections (CaC)

TBD

### 7. Conclusion (Real use case) - Run a Playbook Using EE's and vault on AWX / Tower

AWX on DEV & STAGING (using EE and vault)
