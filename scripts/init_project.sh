#!/bin/bash

###############################################################################
# Filename: init_project.sh
# Description: Ansible project's generic environment initilization script
# version: 1.0
# Author: Jordi Bericat
#         jordi.bericat@global.ntt
#         NTT - Managed Services - IA LAB
#
###############################################################################

######### SECTION 1: Variable initialization ##################################

read -p "Paste your SCM token: " TOKEN
read -p "Type the NUMERIC project ID: " PROJECT_ID
read -p "Type the ansible version you want to enable for this project: " ANSIBLE_VERSION

######### SECTION 2: Base OS packages Installation ############################

sudo apt-get install python3 python3.8-venv pip git

######### SECTION 3: Git repository initialization ############################

# 3.1 En primer lugar creamos el repositorio en la SCM de NTT - IALAB - ABANCA:
# https://scm.dimensiondata.com/ialab/ms/abanca/

cd ~/MyStuff/Repos/
git clone https://oauth2:${TOKEN}@scm.dimensiondata.com/ialab/ms/abanca/automation_pr_${PROJECT_ID}.git
# SECURITY COMPLIANCE: DELETE TOKEN FROM MEM, HISTORY & ./bash_history
TOKEN=null
head -n -1 ~/.bash_history > tmp.txt && mv tmp.txt ~/.bash_history
history -c # This is a bit overkill, though

cd automation_pr_0001
python3 -m venv pr_0001
source venv pr_0001/bin/activate

# 3.2 Seguidamente definimos la estructura del repositorio:

touch .gitignore && echo pr_0001 > .gitignore
mkdir src \
src/inventories/ \
src/inventories/development \
src/inventories/development/group_vars \
src/inventories/development/host_vars \
src/inventories/staging \
src/inventories/production \
src/playbooks/ \
src/roles/ \
src/.ansible_vault/ \
src/scripts
touch src/inventories/development/hosts
echo "[f5-bigip-ltm_group]" >> src/inventories/development/hosts
echo "localhost" >> src/inventories/development/hosts
touch src/scripts/init_project.sh
touch src/scripts/create_vault.sh
chmod 0700 src/scripts/init_project.sh
chmod 0700 src/scripts/create_vault.sh

# TO-DO: ansible.cfg, roles, etc

######### SECTION 4: Virtual environment initialization #######################

# read -p "Type the NUMERIC project ID: " PROJECT_ID
# read -p "Type the ansible version you want to enable for this project: " ANSIBLE_VERSION
# ^_________ Moved to section 1
cd ~/MyStuff/Repos/automation_pr_${PROJECT_ID}
source pr_${PROJECT_ID}/bin/activate

######### SECTION 5: Generic pip packages installation ########################

# 5.1 - Ansible 2.9 install 

pip3 install ansible==${ANSIBLE_VERSION}

# 5.2 - Using this Jinja2 versions fixes compatibilities with several ansible's 
#       2.9 plug-ins:

# [WARNING]: Skipping plugin (/home/user/MyStuff/Repos/automation_pr_0001/pr_0001/lib/python3.8/site-packages/ansible/plugins/filter/core.py) as it seems to be invalid: cannot import name 'environmentfilter' from
# 'jinja2.filters' (/home/user/MyStuff/Repos/automation_pr_0001/pr_0001/lib/python3.8/site-packages/jinja2/filters.py)

# [WARNING]: Skipping plugin (/home/user/MyStuff/Repos/automation_pr_0001/pr_0001/lib/python3.8/site-packages/ansible/plugins/filter/mathstuff.py) as it seems to be invalid: cannot import name 'environmentfilter'
# from 'jinja2.filters' (/home/user/MyStuff/Repos/automation_pr_0001/pr_0001/lib/python3.8/site-packages/jinja2/filters.py)

pip uninstall jinja2
pip install jinja2==3.0.3

# OBSERVACIONES: Es mejor no instalar ansible con apt-get install (system wide) 
# y en su lugar hacerlo con pip3 a nivel de entorno virtual e indicando 
# exactamente la versión que se quiere instalar.

######### SECTION 5: Specific pip packages installation #######################

pip install f5-sdk
pip install netaddr
ansible-galaxy collection install f5networks.f5_modules:==1.16.0 --force

# TO-DO: Use requirements.txt file

# TO-DO: Crate a menu so it asks which network devices we are going to work 
#        with on the new project

###############################################################################
#################################### EOF ######################################
###############################################################################

