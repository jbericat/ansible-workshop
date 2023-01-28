# Ansible Automation - CLI Commands

```bash
ansible-playbook -i environments/dev ANSCGR001_001_AAP-STATS_F5-BIGIP_ssh.yml --user=root -e 'devices_environment="dev" date_stats="2023-01" target_devices="f5bigip"' --ask-pass
```
