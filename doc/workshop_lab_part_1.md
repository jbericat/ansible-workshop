# Ansible Workshop part 1: Entry level

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
| [workshop_lab_part_1.yml](workshop_lab_part_1.yml) | Ansible playbook that gathers all the F5-BIGIP Balanced Services (that is, virtual servers and pools) on a specific month |

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

### 2. Create a python venv to run Ansible locally from CLI

Since on this PoC version we still don't integrate the so called Ansible
Execution Environments, then we're g must first configure a python venv prior the  execution and then install the
ansible packages, as well as the f5-bigip imperative modules collection for
ansible.

```bash
python3 -m venv ansible_venv
source /ansible_venv/bin/activate
pip install ansible-core 2.13.7
ansible-galaxy collection install f5networks.f5_modules:=1.16.0
sudo apt-get install sshpass
```

**IMPORTANT NOTICE:** Do not install the sshpass apt package on the
staging environment yet, so we can point out the benefits of using
Ansible EE's instead of venvs.

### 3. Run a playbook using ansible's built-in modules via SSH using interactive authentication

Once the venv is configured, we will use the ansible-playbook command from the
CLI to run the automation, just setting the different inventory files as
arguments when running the command (-i), as well as the device's groups we'll
connect to (-l). On this first activity though, we won't be storing any private
key on the Ansibles control node (that is, we just type the device's ssh
password interactively at the moment of the playbook execution).

#### 3.1. Development environment

```bash
ansible-playbook -i environments/dev \
workshop_lab_part_1.yml --user=root \
-e 'devices_environment="dev" automation_id="ANSAB001/001" \
date_stats="2023-01"' -l f5bigip --ask-pass
```

#### 3.2. Staging environment

```bash
ansible-playbook -i environments/staging \
workshop_lab_part_1.yml --user=root \
-e 'devices_environment="dev" automation_id="ANSAB001/001" \
date_stats="2023-01"' -l f5bigip --ask-pass
```

#### 3.3. Production environment

```bash
ansible-playbook -i environments/prod \
workshop_lab_part_1.yml --user=root \
-e 'devices_environment="dev" automation_id="ANSAB001/001" \
date_stats="2023-01"' -l f5bigip --ask-pass
```

### 4. Run a playbook using ansible's built-in modules via SSH using a private key

#### 4.1. Creating the ssh-key

```bash
ssh-keygen
```

#### 4.2. Installing the public key on the remote F5-devices devices

```bash
eval
ssh-agent
```

#### 4.3. Installing the private key on the Ansible's control node

```bash
scp
```

#### 4.4. Running the playbook seamlessly (with no interaction)

##### 4.4.1. Development environment

```bash
ansible-playbook
```

##### 4.4.2. Staging environment

```bash
ansible-playbook
```

##### 4.4.3. Production environment

We won't perform these activity on the production environment since we're not
allowed to transfer not-validated public keys to the production F5 devices for
security reasons, but I'm sure we got the point already, so there is no need
nontheless.
