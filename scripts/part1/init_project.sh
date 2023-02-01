#!/bin/bash

# Init project structure

mkdir \
 environments/ \
 environments/dev \
 environments/dev/.vault \
 environments/dev/group_vars \
 environments/dev/host_vars \
 environments/staging \
 environments/staging/.vault \
 environments/staging/group_vars \
 environments/staging/host_vars \
 environments/prod \
 environments/prod/.vault \
 environments/prod/group_vars \
 environments/prod/host_vars \
 logs

touch \
 .gitignore \
 environments/dev/hosts \
 environments/staging/hosts \
 environments/prod/hosts \
 workshop_lab_part_1.yml

echo *_venv > .gitignore
