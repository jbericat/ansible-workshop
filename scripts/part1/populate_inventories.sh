#!/bin/bash

# DEVELOPMENT
cat << EOF > environments/dev/hosts
[f5bigip]
f5bigip[01:03].dev.cgr-lab.lan
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
