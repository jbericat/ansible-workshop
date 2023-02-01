#!/bin/bash

# DEVELOPMENT
cat << EOF > environments/dev/hosts
[f5bigip]
f5bigip[01:03].dev.cgr-lab.lan
EOF

cat << EOF > environments/dev/group_vars/f5bigip.yml
f5_provider:
  user: "admin"
  password: "CGR123ABANCA"
  server: "{{ inventory_hostname }}"
  server_port: 443
  validate_certs: no
  transport: rest
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
