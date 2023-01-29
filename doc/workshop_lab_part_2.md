# Ansible Workshop part 2: Automation deployment with Ansible

## Table of Contents

- [Ansible Workshop part 2: Automation deployment with Ansible](#ansible-workshop-part-2-automation-deployment-with-ansible)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Activities](#activities)
    - [1. Create an Ansible EE for this use case](#1-create-an-ansible-ee-for-this-use-case)
    - [2. Deploy the EE on vscode](#2-deploy-the-ee-on-vscode)
    - [3. Run a playbook using EE's instead of venvs via TUI](#3-run-a-playbook-using-ees-instead-of-venvs-via-tui)
    - [4. Encrypting sensitive data with ansible Vault](#4-encrypting-sensitive-data-with-ansible-vault)
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

- deactivate venv
- ansible-builder (TBD paste instructions here from IALAB001 repo)

### 2. Deploy the EE on vscode

TBD

### 3. Run a playbook using EE's instead of venvs via TUI

1) install ansible-navigator

```bash
python3 -m venv lab_part2_venv
source lab_part2_venv/bin/activate
pip install ansible-navigator
```

2) Running the playbook via Ansible-Navigator on DEV

```bash
ansible-navigator --eei quay.io/jordi_bericat/awx-ee:2.13-latest \
 run workshop_lab_part_2.yml \
 -i environments/dev/ \
 -e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
 -l f5bigip
```

**PROS:**

- Full automation (no need neither of specifyng SSH password on runtime nor of creating / setting SSH keys)
- Total portability and scalability of the environment (we can use the same EE container in all envs, even in vscode for debugging and coding purposes!)

**CONS:**

- Poor security measures (the F5 devices' password is stored in plaintext on the group vars)
- Still not very user friendly

### 4. Encrypting sensitive data with ansible Vault

Encrypt password with vault (encrypt string)

### 5. Installing AWX for DEV & STAGING environments

- install minikube
- install AWX

### 6. Create AWX / Tower objects using Ansible galaxy collections (CaC)

TBD

### 7. Conclusion (Real use case) - Run a Playbook Using EE's and vault on AWX / Tower

AWX on DEV & STAGING (using EE and vault)
