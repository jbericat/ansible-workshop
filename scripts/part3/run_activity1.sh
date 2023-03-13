ansible-navigator \
    run workshop_lab_part_3.yml \
    --eei quay.io/jordi_bericat/ansible-ee:2.13-latest \
    --inventory environments/dev/ \
    --limit f5bigip \
    --extra-vars @debug/part_3_input.yml \
    --vault-password-file ~/.vault/.dev_vault_password \
    --lf logs/ansible-navigator.log \
    --pas logs/{playbook_name}-artifact-{time_stamp}.json

    # --forks 1 \
