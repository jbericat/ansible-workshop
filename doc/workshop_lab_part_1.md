# Ansible Workshop part 1: Introduction to Ansible

[TOC]

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
devices through the SSH port. More precisely we will set three inventory files
for multiple environments (development, staging and production), so we will be
able to run the same playbook against the different sets of F5 devices.

| **Playbook** | **Description** |
|-|-|
| [workshop_lab_part_1.yml](workshop_lab_part_1.yml) | Ansible playbook that gathers all the F5-BIGIP Balanced Services (that is, virtual servers and pools) on a specific month via SSH |

## Activities

### 1. Preparing the developer workstation

**OS:** Either any modern Linux distribution or WSL 2.0

**IDE:** VScode 1.74.3

**VSCode extensions:**

| **Extension Name** | **Publisher** | **Notes** |
|-|-|-|
|WSL|Microsoft|Mandatory|
|Python|Microsoft|Mandatory|
|YAML|Red Hat|Mandatory|
|Ansible|Red Hat|Mandatory|
|jinja|Wholroyd|Recommended|
|Indent rainbow|oderwaty|Optional|
|Material icon|Philipp Kief|Optional|

### 2. Setting-ip the Git repository

#### 2.1. Creating the repository

First we need to create the repository on the Git platform of our choice. Once
done, we can use it's ssh uri to access the repo from all three environments
(dev, staging & prod).

| GitHub ssh uri |
|- |
| git@github.com:NTT-EU-ES/ialab-ansible-workshop.git |

#### 2.2. Creating the deploy keys

For the sake of agility accessing the repo though, we're going to create an ssh
private/public key pair and use it as a deployment key. To be on the safe side
though, we're going to create two different pairs; one with RW access to use on
the development environment and a second one with only RO permissions to use on
both the staging and production environment. This way we increase the security
of our work and we also avoid messing-out our developments by pushing-up code
by mistake from the wrong environment.

We can create both pairs from our developer workstation:

##### 2.2.1. Creating the RW personal SSH key

```bash
ssh-keygen -t ed25519 -C "jordi.bericat@global.ntt"
```

- **Private key:** /home/jbericat/.ssh/id_ed25519_ansible_workshop
- **Public key:** /home/jbericat/.ssh/id_ed25519_ansible_workshop.pub
- **password:** MySuperSecretPassword (or not!)

##### 2.2.2. Creating the RO personal deploy key

```bash
ssh-keygen -t ed25519 -C "jordi.bericat@global.ntt"
```

##### 2.3. Deploying both public keys on GitHub

TBD PASTE SCREENSHOTS USING GITHUB WEB UI

#### 2.4. Adding both private keys on the pipeline environments

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

### 3. Creating a python venv to run Ansible locally from the CLI

Since on this PoC version we still don't integrate the so called Ansible
Execution Environments, then we're g must first configure a python venv
**ON ALL THE ENVIRONMENTS** prior the execution and then install the ansible
packages. We'll also the f5-bigip imperative modules collection for ansible
and some other OS packages, but be aware that those do not go into the venv!!

```bash
python3 -m venv ansible_venv
source /ansible_venv/bin/activate
pip install ansible-core 2.13.7
ansible-galaxy collection install f5networks.f5_modules:=1.16.0
sudo apt-get install sshpass
```

Tip: Do not forget to add a .gitignore file on the repository root to tell git
not to sync the venv on the repository.

### 4. Creating a playbook using ansible's built-in modules to run an automation via SSH using interactive authentication

Now we're going to write a plabook to run the ansible automation we described
on the introduction section:

```yaml
TBD - PASTE PART 1 PB HERE
```

Once the venv and the playook itself are on place, we will use the
ansible-playbook command from the CLI to run the automation, just setting the
different inventory files as arguments when running the command (-i), as well
as the device's groups we'll connect to (-l). On this first activity though,
we won't be storing any private key on the Ansibles control node (that is, we
just type the device's ssh password interactively at the moment of the playbook
execution).

#### 4.1. Development environment

```bash
ansible-playbook -i environments/dev workshop_lab_part_1.yml \
 -l f5bigip \
 -e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
 --user=admin \
 --ask-pass
```

#### 4.2. Staging environment

```bash
ansible-playbook -i environments/staging workshop_lab_part_1.yml \
 -l f5bigip \
 -e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
 --user=admin \
 --ask-pass
```

#### 4.3. Production environment

```bash
ansible-playbook -i environments/prod workshop_lab_part_1.yml \
 -l f5bigip \
 -e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
 --user=admin \
 --ask-pass
```

### 4.4. Summing-up: Pros and cons of this ansible automation method

**PROS**

- We reach a certain level of task automation to execute the same tmsh command on different F5 devices at once

**CONS**

- not fully automated (we must type the password each time), so it does not scale well
- Environment not portable (we must replicate the venv on all the environment, which is painful and prone to deadlocks due to possible OS package dependencies that cannot be met and so on)
- Not user friendly at all (not skilled CLI users would have a bad time trying to run these commands by themselves)

#### 4.5. Documenation references

<https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_vars_facts.html>

### 5. Running the playbook using ansible's built-in modules via SSH using a private key

#### 5.1. Creating the ssh-key

```bash
ssh-keygen -t ed25519
```

- **Private key:** /home/jbericat/.ssh/id_ed25519_f5bigip
- **Public key:** /home/jbericat/.ssh/id_ed25519_f5bigip.pub
- **password:** 123456

#### 5.2. Deploying the public key on the remote F5-devices devices

```bash
scp /home/jbericat/.ssh/id_ed25519_f5bigip.pub admin@f5bigip01.dev.cgr-lab.lan:/home/admin/.ssh/authorized_keys
scp /home/jbericat/.ssh/id_ed25519_f5bigip.pub admin@f5bigip03.dev.cgr-lab.lan:/home/admin/.ssh/authorized_keys
scp /home/jbericat/.ssh/id_ed25519_f5bigip.pub admin@f5bigip01.staging.cgr-lab.lan:/home/admin/.ssh/authorized_keys
scp /home/jbericat/.ssh/id_ed25519_f5bigip.pub admin@f5bigip03.staging.cgr-lab.lan:/home/admin/.ssh/authorized_keys
```

#### 5.3. Adding the private key identity on the Ansible's control node

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_f5bigip
```

#### 5.4. Running the playbook seamlessly (with no interaction)

Now we can run the playbook without human interaction at all, which is kind off cool :)

##### 5.4.1. Development environment

```bash
ansible-playbook -i environments/dev workshop_lab_part_1.yml \
 -l f5bigip \
 -e 'automation_id="ANSAB001/001" date_stats="2023-01"' \
 --user=admin \
 --private-key ~/.ssh/id_ed25519_f5bigip
```

##### 5.4.2. Staging & Production environment

We won't perform this activity on those environments since we're not allowed
to transfer not-validated public keys to the production F5 devices due to
security concerns. Anyway, I'm sure you all got the point already from the
previous activity, so there is no need to do it again.

##### 5.4.3. Summing-up: Pros and cons of this ansible automation method

**PROS**

- We can execute the same tmsh command on different F5 devices at once
- Increased level of automation (no human interaction needed to run the PB)

**CONS**

- Not full automation yet (we still have to enable the ssh-agent every now and then)
- Environment still not portable / scalable
- Not user friendly

##### 5.4.5. Documentation references

<https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ssh_connection.html>
<https://medium.com/openinfo/ansible-ssh-private-public-keys-and-agent-setup-19c50b69c8c>
