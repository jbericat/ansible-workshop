# Ansible Workshop part 1: Introduction to Ansible

## Table of Contents

- [Ansible Workshop part 1: Introduction to Ansible](#ansible-workshop-part-1-introduction-to-ansible)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Activities](#activities)
    - [1. Preparing the developer workstation](#1-preparing-the-developer-workstation)
      - [1.1. Software packages](#11-software-packages)
      - [1.2 To know more](#12-to-know-more)
    - [2. Setting-up the Git repository](#2-setting-up-the-git-repository)
      - [2.1. Creating the repository](#21-creating-the-repository)
      - [2.2. Creating the deploy keys](#22-creating-the-deploy-keys)
        - [2.2.1. Creating the RW personal SSH key](#221-creating-the-rw-personal-ssh-key)
        - [2.2.2. Creating the RO personal deploy key](#222-creating-the-ro-personal-deploy-key)
      - [2.3. Deploying both public keys on GitHub](#23-deploying-both-public-keys-on-github)
      - [2.4. Adding both private keys on each environment](#24-adding-both-private-keys-on-each-environment)
      - [2.5. To know more](#25-to-know-more)
    - [3. Create a python virtual environment](#3-create-a-python-virtual-environment)
      - [3.1 Creating a python venv to run Ansible locally from the CLI](#31-creating-a-python-venv-to-run-ansible-locally-from-the-cli)
      - [3.2. To know more](#32-to-know-more)
    - [4. Create the project structure and populate the inventory](#4-create-the-project-structure-and-populate-the-inventory)
      - [4.1. Project structure](#41-project-structure)
      - [4.2. Populating the environments' inventory host files](#42-populating-the-environments-inventory-host-files)
      - [4.3. To know more](#43-to-know-more)
    - [5. Creating a playbook using ansible's built-in modules to run an automation via SSH using interactive authentication](#5-creating-a-playbook-using-ansibles-built-in-modules-to-run-an-automation-via-ssh-using-interactive-authentication)
      - [5.1. Creating the playbook file](#51-creating-the-playbook-file)
      - [5.2. Running the playbook](#52-running-the-playbook)
        - [5.2.1 Development environment](#521-development-environment)
        - [5.2.2. Staging environment](#522-staging-environment)
        - [5.2.3. Production environment](#523-production-environment)
      - [5.3. Summing-up: Pros and cons of this ansible automation method](#53-summing-up-pros-and-cons-of-this-ansible-automation-method)
      - [5.4. To know more](#54-to-know-more)
    - [6. Running the playbook using ansible's built-in modules via SSH using a private key](#6-running-the-playbook-using-ansibles-built-in-modules-via-ssh-using-a-private-key)
      - [6.1. Creating the ssh-key](#61-creating-the-ssh-key)
      - [6.2. Deploying the public key on the remote F5-devices devices](#62-deploying-the-public-key-on-the-remote-f5-devices-devices)
      - [6.3. Adding the private key identity on the Ansible's control node](#63-adding-the-private-key-identity-on-the-ansibles-control-node)
      - [6.4. Running the playbook seamlessly (with no interaction)](#64-running-the-playbook-seamlessly-with-no-interaction)
        - [6.4.1. Development environment](#641-development-environment)
        - [6.4.2. Staging \& Production environment](#642-staging--production-environment)
      - [6.5. Summing-up: Pros and cons of this ansible automation method](#65-summing-up-pros-and-cons-of-this-ansible-automation-method)
      - [6.6. To know more](#66-to-know-more)

## Introduction

This is an elementary PoC demo lab where we will show-off the basics of ansible
automation.

Here, our main goal will be to demonstrate how we can execute a CLI command
on several network devices in an automated way, considering that these devices
belong to different environments. On this very example we're going to automate
the gathering of data from F5-BIGIP devices, but they could be any
kind of network device (either physical or virtualized), server, or whatever
system accessible through SSH.

To do so, we are going to use several Ansible inventory files to reach the F5
devices via SSH. More precisely we will set three inventory files for multiple
environments (development, staging and production), so we will be able to run
the same playbook against the different sets of F5 devices.

<kbd>![image](https://user-images.githubusercontent.com/110392930/215433778-5419f190-b561-44fe-afab-6083a932f4ca.png)
</kbd>

| **Playbook**                                       | **Description**                                                                                                                   |
| -------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| [workshop_lab_part_1.yml](workshop_lab_part_1.yml) | Ansible playbook that gathers all the F5-BIGIP Balanced Services (that is, virtual servers and pools) on a specific month via SSH |

## Activities

### 1. Preparing the developer workstation

#### 1.1. Software packages

**OS:** Either any modern Linux distribution or WSL 2.0

**IDE:** VScode 1.74.3

**VSCode extensions:**

| **Extension Name** | **Publisher** | **Notes**   |
| ------------------ | ------------- | ----------- |
| WSL                | Microsoft     | Mandatory   |
| Python             | Microsoft     | Mandatory   |
| YAML               | Red Hat       | Mandatory   |
| Ansible            | Red Hat       | Mandatory   |
| jinja              | Wholroyd      | Recommended |
| Indent rainbow     | oderwaty      | Optional    |
| Material icon      | Philipp Kief  | Optional    |

#### 1.2 To know more

- https://marketplace.visualstudio.com/items?itemName=redhat.ansible
- https://www.ansible.com/resources/webinars-training/using-the-new-vs-code-extension-for-ansible
- https://github.com/ansible/vscode-ansible

### 2. Setting-up the Git repository

#### 2.1. Creating the repository

First we need to create the repository on the Git platform of our choice. Once
done, we can use it's ssh uri to access the repo from all three environments
(dev, staging & prod).

| GitHub ssh uri                                      |
| --------------------------------------------------- |
| git@github.com:NTT-EU-ES/ialab-ansible-workshop.git |

#### 2.2. Creating the deploy keys

For the sake of agility accessing the repo though, we're going to create an ssh
private/public key pair and use it as a deployment key. To be on the safe side
though, we're going to create two different pairs; one with RW access to use on
the development environment and a second one with only RO permissions to use on
both the staging and production environment. This way we increase the security
of our work and we also avoid messing-out our developments by pushing-up code
by mistake from the wrong environment.

We can create both key pairs from our developer workstation:

##### 2.2.1. Creating the RW personal SSH key

```bash
ssh-keygen -t ed25519 -C "jordi.bericat@global.ntt"
```

- **Private key:** /home/jbericat/.ssh/id_ed25519_ansible_workshop_RW
- **Public key:** /home/jbericat/.ssh/id_ed25519_ansible_workshop_RW.pub
- **password:** MySuperSecretPassword

##### 2.2.2. Creating the RO personal deploy key

```bash
ssh-keygen -t ed25519 -C "jordi.bericat@global.ntt"
```

- **Private key:** /home/jbericat/.ssh/id_ed25519_ansible_workshop_RO
- **Public key:** /home/jbericat/.ssh/id_ed25519_ansible_workshop_RO.pub
- **password:** MySuperSecretPassword

#### 2.3. Deploying both public keys on GitHub

![image](https://user-images.githubusercontent.com/110392930/216042070-c61e010e-0555-40f0-816a-f2e2dd48fa6f.png)

#### 2.4. Adding both private keys on each environment

**DEV ENVIRONMENT**

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_ansible_workshop_RW
```

**STAGING & PROD ENVIRONMENTS**

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_ansible_workshop_RO
```

#### 2.5. To know more

- https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
- https://linuxize.com/post/gitignore-ignoring-files-in-git/
- https://github.com/github/gitignore
- https://stackoverflow.com/questions/13541615/how-to-remove-files-that-are-listed-in-the-gitignore-but-still-on-the-repositor


### 3. Create a python virtual environment

#### 3.1 Creating a python venv to run Ansible locally from the CLI

Since on this PoC version we still don't integrate the so called Ansible
Execution Environments, then we must first configure a python venv
**ON ALL THE ENVIRONMENTS** prior the PB execution and then install the ansible
packages. We'll also install the F5-BIGIP imperative modules collection for 
Ansible and some other OS packages, but be aware that those do not go into the
venv!!

```bash
python3 -m venv ansible-lab1_venv
source ansible-lab1_venv/bin/activate
pip install ansible-core==2.13.7
ansible-galaxy collection install f5networks.f5_modules:=1.22.0
sudo apt-get install sshpass
```

Tip: Do not forget to add a .gitignore file on the repository root to tell git
not to sync the venv on the repository.

#### 3.2. To know more

- https://www.redhat.com/sysadmin/python-venv-ansible

### 4. Create the project structure and populate the inventory

#### 4.1. Project structure

```bash
#!/bin/bash

# Init project structure

mkdir \
 environments/ \
 environments/dev \
 environments/staging \
 environments/prod \
 logs

touch \
 .gitignore \
 environments/dev/hosts \
 environments/staging/hosts \
 environments/prod/hosts \
 workshop_lab_part_1.yml

echo *_venv > .gitignore
```

#### 4.2. Populating the environments' inventory host files

```bash
#!/bin/bash

# DEVELOPMENT
cat << EOF > environments/dev/hosts
[f5bigip]
f5bigip[01:03].dev.cgr-lab.lan
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

#### 4.3. To know more

- https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html
- https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#host-variables
- https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html#group-variables


### 5. Creating a playbook using ansible's built-in modules to run an automation via SSH using interactive authentication

#### 5.1. Creating the playbook file

Now we're going to write a plabook to run the ansible automation we described
on the introduction section:

```yaml
---
- name: >
    PLAYBOOK - "workshop_lab_part_1.yml" (F5-BIGIP Automation via SSH on
    multiple environments using Ansible inventory files)
  hosts: all
  gather_facts: no
  tasks:

  - name: >
      1. Testing the SSH connection to the [{{ inventory_hostname }}]
      F5-BIGIP device from the
      [{{ inventory_file|regex_replace(playbook_dir,'') }}] inventory
    ansible.builtin.ping:

  - name: >
      2. Gathering all the balanced services created for the
      [{{ inventory_hostname }}] F5-BIGIP device from the
      [{{ inventory_file|regex_replace(playbook_dir,'') }}] inventory via
      SSH
    ansible.builtin.shell:
      cmd: >
        tmsh list ltm virtual creation-time description |
        grep -A 1 '{{ date_stats }}' |
        grep '{{ automation_id }}' -c
    register: results
    ignore_errors: true

  - name: 3. SHOW RESULTS
    debug:
      msg: >
        total balanced services created on [{{ date_stats }}] =
        [{{ results.stdout|default(none) }}]
...

```

#### 5.2. Running the playbook

Once the venv and the playook itself are on place, we will use the
`ansible-playbook` command from the CLI to run the automation, just setting the
different inventory files (using either the `--inventory` or `-i` option) when 
running the `ansible-playbook` command, as well as the device's group we'll 
connect to (using either the `--limit` or `-l` option). We'll also pass some 
variables on runtime to the PB using the `--extra-vars` or `-e` option. On this 
first activity though, we won't be using any private key to connect to the 
managed nodes- that is, we just type the device's SSH password interactively at
the moment of the PB execution (using the `--user` option to tell ansible which
user we want to use to perform the SSH connection, along with the `--ask-pass`
option). 

##### 5.2.1 Development environment

```bash
ansible-playbook workshop_lab_part_1.yml \
    --inventory environments/dev \
    --limit f5bigip \
    --extra-vars 'automation_id="ANSAB001/001" date_stats="2023-01"' \
    --user=admin \
    --ask-pass
```

##### 5.2.2. Staging environment

we wont do this part of the activity, but the command to run the same PB on the
staging inventory just needs a slight change (that is, to specify the new
inventory with the `--inventory` option)

```bash
ansible-playbook workshop_lab_part_1.yml \
    --inventory environments/staging \
    --limit f5bigip \
    --extra-vars 'automation_id="ANSAB001/001" date_stats="2023-01"' \
    --user=admin \
    --ask-pass
```

##### 5.2.3. Production environment

we neither wont do this part of the activity, but the command to run the same
PB on the staging inventory just needs a slight change (that is, to specify the
new inventory with the `--inventory` option)

```bash
ansible-playbook workshop_lab_part_1.yml \
    --inventory environments/staging \
    --limit f5bigip \
    --extra-vars 'automation_id="ANSAB001/001" date_stats="2023-01"' \
    --user=admin \
    --ask-pass
```

#### 5.3. Summing-up: Pros and cons of this ansible automation method

**PROS**

- We reach a certain level of task automation to execute the same tmsh command on different F5 devices at once

**CONS**

- not fully automated (we must type the password each time), so it does not scale well
- Environment not portable (we must replicate the venv on all the environment, which is painful and prone to deadlocks due to possible OS package dependencies that cannot be met and so on)
- Not user friendly at all (not skilled CLI users would have a rough time trying to run these commands by themselves)

#### 5.4. To know more

- https://docs.ansible.com/ansible/latest/reference_appendices/YAMLSyntax.html
- https://ansible-lint.readthedocs.io/
- https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_intro.html
- https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html
- https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html
- https://docs.ansible.com/ansible/latest/playbook_guide/complex_data_manipulation.html
- https://docs.ansible.com/ansible/2.7/user_guide/playbooks_filters.html
- https://jinja.palletsprojects.com/en/3.0.x/templates/#jinja-filters
- https://docs.ansible.com/ansible/latest/collections/ansible/builtin/index.html
- https://docs.ansible.com/ansible/devel/collections/ansible/utils/index.html
- https://docs.ansible.com/ansible/latest/collections/index.html

### 6. Running the playbook using ansible's built-in modules via SSH using a private key

#### 6.1. Creating the ssh-key

```bash
ssh-keygen -t ed25519
```

- **Private key:** /home/user/.ssh/id_ed25519_f5bigip
- **Public key:** /home/user/.ssh/id_ed25519_f5bigip.pub
- **password:** 123456

#### 6.2. Deploying the public key on the remote F5-devices devices

```bash
scp /home/user/.ssh/id_ed25519_f5bigip.pub admin@f5bigip01.dev.cgr-lab.lan:/home/admin/.ssh/authorized_keys
scp /home/user/.ssh/id_ed25519_f5bigip.pub admin@f5bigip03.dev.cgr-lab.lan:/home/admin/.ssh/authorized_keys
scp /home/user/.ssh/id_ed25519_f5bigip.pub admin@f5bigip01.staging.cgr-lab.lan:/home/admin/.ssh/authorized_keys
scp /home/user/.ssh/id_ed25519_f5bigip.pub admin@f5bigip03.staging.cgr-lab.lan:/home/admin/.ssh/authorized_keys
```

#### 6.3. Adding the private key identity on the Ansible's control node

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_f5bigip
```

#### 6.4. Running the playbook seamlessly (with no interaction)

Now we can run the playbook without human interaction at all, which is kind off cool :)

##### 6.4.1. Development environment

```bash
ansible-playbook workshop_lab_part_1.yml \
    --inventory environments/dev \
    --limit f5bigip \
    --extra-vars 'automation_id="ANSAB001/001" date_stats="2023-01"' \
    --user=admin \
    --private-key ~/.ssh/id_ed25519_f5bigip
```

##### 6.4.2. Staging & Production environment

We won't perform this activity on those environments since we're not allowed
to transfer not-validated public keys to the production F5 devices due to
security concerns. Anyway, I'm sure you all got the point already from the
previous activity, so there is no need to do it again.

#### 6.5. Summing-up: Pros and cons of this ansible automation method

**PROS**

- We can execute the same tmsh command on different F5 devices at once
- Increased level of automation (no human interaction needed to run the PB)

**CONS** 

- Not full automation yet (we still have to enable the ssh-agent every now and then)
- Environment still not portable / scalable
- Not very user friendly

#### 6.6. To know more

- https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ssh_connection.html
- https://medium.com/openinfo/ansible-ssh-private-public-keys-and-agent-setup-19c50b69c8c
