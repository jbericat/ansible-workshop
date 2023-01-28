# Ansible Workshop

## 1. Workshop Stages - Table of contents

| Stage | Resource |
|-|-|
| Presentation Speech - The whole picture | TBD (Power Point / OneNote) |
| Demostration Lab part 1 - Introduction to Ansible | [/doc/workshop_lab_part_1.md](/doc/workshop_lab_part_1.md) |
| Demostration Lab part 2 - Automation deployment with Ansible | [/doc/workshop_lab_part_2.md](/doc/workshop_lab_part_2.md) |
| Beyond the Workshop - Where to learn more about Ansible & AAP | TBD (Websites, Linked-in Trainings, Books, Social, Events) |

## 2. Environments

### 2.1. Common: Ansible Execution Environment (EE)

- Ansible Core 2.13.7
- F5-BIGIP 15.1.5.1 Build 0.230.14
- F5-Modules imperative collection for Ansible 1.16.0
- Python 3.9.13

### 2.2. Development Environment

- qemu-kvm 7.1.0-3.el9 on Centos 9 Stream
- GNS3 2.2.33.1
- Kubernetes 1.25.3 / Minikube 1.28.0 on Ubuntu 20.04
- Ansible AWX 21.8.0 -> [awx.dev.cgr-lab.lan](http://awx.dev.cgr-lab.lan)
- GitHub Enterprise -> <https://github.com/NTT-EU-ES/>

### 2.3. Staging Environment

- qemu-kvm 2.4.0 on RHEL 8
- EVE-ng 4.0.1-86-PRO
- Kubernetes 1.25.3 / Minikube 1.28.0 on Ubuntu 20.04
- Ansible AWX 21.8.0 -> [awx.staging.cgr-lab.lan](http://awx.staging.cgr-lab.lan)
- GitHub Enterprise -> <https://github.com/NTT-EU-ES/>

### 2.4. Production Environment

- Red Hat OpenShift
- Ansible Automation Platform (Ansible Tower) 4.1.2 -> [tower.abanca.com](tower.abanca.com)
- GiLab -> <https://abanca.gitlab.com>

## 3. Credits

- *Jordi Bericat Ruz*
- *jordi.bericat@global.ntt*
- *NTT Spain S.L. - Managed Services (CGR //ABANCA) - IALAB*

------------------------------
