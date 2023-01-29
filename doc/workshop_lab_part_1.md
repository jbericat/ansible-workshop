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

### 2. Create a python venv to run Ansible locally from the CLI

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
ansible-playbook -i environments/dev workshop_lab_part_1.yml \
 --user=admin \
 -e 'devices_environment="staging" automation_id="ANSAB001/001" \
 date_stats="2023-01"' \
 -l f5bigip \
 --ask-pass
```

#### 3.2. Staging environment

```bash
ansible-playbook -i environments/staging workshop_lab_part_1.yml \
 --user=admin \
 -e 'devices_environment="staging" automation_id="ANSAB001/001" \
 date_stats="2023-01"' \
 -l f5bigip \
 --ask-pass
```

#### 3.3. Production environment

```bash
ansible-playbook -i environments/prod workshop_lab_part_1.yml \
 --user=admin \
 -e 'devices_environment="dev" automation_id="ANSAB001/001" \
 date_stats="2023-01"' \
 -l f5bigip \
 --ask-pass
```

### 3.4. Summing-up: Pros and cons of this ansible automation method

**PROS**

- We can execute the same tmsh command on different F5 devices at once

**CONS**

- not fully automated (we must type the password each time), so it does not scale well
- Environment not portable
- Not user friendly

### 4. Run a playbook using ansible's built-in modules via SSH using a private key

#### 4.1. Creating the ssh-key

```bash
ssh-keygen -t ed25519
```

- **Private key:** /home/jbericat/.ssh/id_ed25519_f5bigip
- **Public key:** /home/jbericat/.ssh/id_ed25519_f5bigip.pub
- **password:** 123456

#### 4.2. Deploying the public key on the remote F5-devices devices

```bash
scp /home/jbericat/.ssh/id_ed25519_f5bigip.pub admin@f5bigip01.dev.cgr-lab.lan:/home/admin/.ssh/authorized_keys
scp /home/jbericat/.ssh/id_ed25519_f5bigip.pub admin@f5bigip03.dev.cgr-lab.lan:/home/admin/.ssh/authorized_keys
scp /home/jbericat/.ssh/id_ed25519_f5bigip.pub admin@f5bigip01.staging.cgr-lab.lan:/home/admin/.ssh/authorized_keys
scp /home/jbericat/.ssh/id_ed25519_f5bigip.pub admin@f5bigip03.staging.cgr-lab.lan:/home/admin/.ssh/authorized_keys
```

#### 4.3. Adding the private key identity on the Ansible's control node

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519_f5bigip
```

#### 4.4. Running the playbook seamlessly (with no interaction)

Now we can run the playbook without human interaction at all, which is kind off cool :)

##### 4.4.1. Development environment

```bash
ansible-playbook -i environments/dev workshop_lab_part_1.yml \
 --user=admin \
 -e 'devices_environment="dev" automation_id="ANSAB001/001" \
 date_stats="2023-01"' \
 -l f5bigip \
 --private-key ~/.ssh/id_ed25519_f5bigip
```

##### 4.4.2. Staging environment

```bash
ansible-playbook -i 
```

##### 4.4.3. Production environment

We won't perform this activity on those environments since we're not
allowed to transfer not-validated public keys to the production F5 devices for
security reasons. Anyway, I'm sure you all got the point already from the
previous activity, so there is no need to do it again.

##### 4.4.4. Summing-up: Pros and cons of this ansible automation method

**PROS**

- We can execute the same tmsh command on different F5 devices at once

**CONS**

- not fully automated (we must type the password each time), so it does not scale well
- Environment not portable
- Not user friendly

##### 4.4.5. To know more

<https://docs.ansible.com/ansible/latest/collections/ansible/builtin/ssh_connection.html>
<https://medium.com/openinfo/ansible-ssh-private-public-keys-and-agent-setup-19c50b69c8c>
