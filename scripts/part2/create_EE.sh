#!/bin/bash

# 1) Installing ansible-builder

pip install ansible-builder

# 2) Defining the Execution Environment

# 2.1) Creating context files structure

rm -rf ~/ansible-builder
mkdir ~/ansible-builder && cd ~/ansible-builder
touch execution-environment.yml requirements.yml requirements.txt bindep.txt 
mkdir context && cd context
touch run.sh && chmod 774 run.sh
cat << EOF > run.sh
#!/bin/bash
ansible-runner worker --private-data-dir=/runner
EOF

# 2.2) Setting Execution Environment global definitions

cd ~/ansible-builder
cat << EOF > execution-environment.yml
---
version: 1

build_arg_defaults:
  EE_BASE_IMAGE: 'quay.io/ansible/ansible-runner:latest'

dependencies:
  galaxy: requirements.yml
  python: requirements.txt
  system: bindep.txt

additional_build_steps:
  append:
    - RUN alternatives --set python /usr/bin/python3
    - COPY --from=quay.io/project-receptor/receptor:latest /usr/bin/receptor /usr/bin/receptor
    - RUN mkdir -p /var/run/receptor
    - ADD run.sh /run.sh
    - CMD /run.sh
    - USER 1000 
    - RUN git lfs install
...
EOF

# 2.3) Setting Galaxy Collections

cat << EOF > requirements.yml
---
collections:
  - name: community.general
  - name: awx.awx
    version: 21.8.0
  - name: f5networks.f5_modules
    version: 1.16.0
...
EOF

# 2.4) Setting Python pip packages

cat << EOF > requirements.txt
urllib3
ansible-lint==6.11.0
pyvmomi==7.0.3
pyvim==3.0.3
EOF

# 2.5) Setting OS Dependencies

cat << EOF > bindep.txt
python38-devel [platform:centos]
subversion [platform:centos]
git-lfs [platform:centos]
EOF

# 3) Running ansible-builder to create the EE

# 3.1) Creating python venv

python3 -m venv builder_venv
source builder_venv/bin/activate

# 3.2) Creating the EE docker container
ansible-builder build --tag quay.io/jordi_bericat/awx-ee:2.13-workshop --context ./context --container-runtime docker

# 3.3) Uploading the EE Container to the quay registry

docker login quay.io
docker push quay.io/jordi_bericat/awx-ee:2.13-workshop
deactivate builder_venv
