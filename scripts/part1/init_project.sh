#!/bin/bash

# Init project structure

mkdir \
    environments/ \
    environments/dev \
    environments/staging \
    environments/prod

touch \
    .gitignore \
    environments/dev/hosts \
    environments/staging/hosts \
    environments/prod/hosts \
    workshop_lab_part_1.yml

echo *_venv > .gitignore
