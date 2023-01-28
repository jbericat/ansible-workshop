#!/bin/bash

###############################################################################
# Filename: create_vault.sh
# Description: Inits the Ansible vault with the device's admin passwords
# version: 2.0
# Author: Jordi Bericat
#         jordi.bericat@global.ntt
#         NTT - Managed Services - IA LAB
#
###############################################################################

read -p "Type the Ansible project ID: " PROJECT_ID
read -p "Type the device admin user ID: " USER_ID
mkdir ~/MyStuff/Repos/${PROJECT_ID}/host_vars/.vault/
ansible-vault create --vault-id ${USER_ID}@prompt ~/MyStuff/Repos/${PROJECT_ID}/host_vars/.vault/${USER_ID}.secret

#################################### EOF ######################################

