# Ansible Workshop part 1: Entry level

*Jordi Bericat*
*jordi.bericat@global.ntt*
*NTT - Managed Services - IALAB*

## 1. Introduction

This is a PoC demo lab where we use Ansible inventory files to reach the F5
devices through the SSH port. More precisely we will set three inventory files
for multiple environments (development, staging and production), so we will be
able to run the same playbook against the different sets of F5 devices.

**Playbook:**

ANSCGR001_001_AAP-STATS_F5-BIGIP_v1.yml

**Description:**

Ansible playbook that gathers all the F5-BIGIP Balanced Services (that is,
virtual servers and pools) on a specific month.

## 2. Activities

### 2.1. Preparing the developer workstation

**OS:** Either any modern Linux distribution or WSL 2.0

**IDE:** VScode 1.74.3

**VSCode extensions:**

- WSL
- Python
- Ansible
- YAML
- jinja
- Indent rainbow
- Material icon

### 2.2. Create a python venv to run Ansible locally from CLI

On this PoC version we do not integrate Ansible Execution
Environments, hence we must configure a python venv prior its
execution and then install the ansible packages, as well as the
f5-bigip imperative modules collection for ansible.

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

### 2.3. Run a playbook using ansible's built-in modules via SSH using interactive authentication

   Once the venv is configured, we will use the ansible-playbook
   command from the CLI to run the automation, just setting the
   different inventory files as arguments when running the command,
   (-e) as well as the device's groups we'll connect to (-l). On
   this first activity though, we won't be storing any private key
   on the Ansibles control node (that is, we just type the device's
   ssh password interactively at the moment of the playbook
   execution).

   Development environment:

   ansible-playbook -i environments/dev \
   ANSCGR001_001_AAP-STATS_F5-BIGIP_v1.yml --user=root \
   -e 'devices_environment="dev" automation_id="ANSAB001/001" \
   date_stats="2023-01"' -l f5bigip --ask-pass

   Staging environment:

   ansible-playbook -i environments/dev \
   ANSCGR001_001_AAP-STATS_F5-BIGIP_v1.yml --user=root \
   -e 'devices_environment="dev" automation_id="ANSAB001/001" \
   date_stats="2023-01"' -l f5bigip --ask-pass

   Production environment:

   ansible-playbook -i environments/dev \
   ANSCGR001_001_AAP-STATS_F5-BIGIP_v1.yml --user=root \
   -e 'devices_environment="dev" automation_id="ANSAB001/001" \
   date_stats="2023-01"' -l f5bigip --ask-pass

3. Run a playbook using ansible's built-in modules via SSH using a private key
   ---------------------------------------------------------------------------

   1) ssh-keygen
   2) instal pub key to f5 devices
   3) eval
   4) ssh-agent
