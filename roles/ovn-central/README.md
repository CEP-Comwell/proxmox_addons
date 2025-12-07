OVN Central Ansible role

Purpose
- Install and configure the OVN central components (northd / central services) on a control host.

Overview
- This role installs packages listed in `ovn_central_packages`, optionally deploys a basic configuration file, and ensures configured services are enabled and running.

Usage
- Include `roles/ovn-central` in a playbook and override variables in `defaults/main.yml` as needed.

Example playbook: `playbooks/ovn-central.yml`

Notes
- The role is intentionally minimal and uses the generic `package` and `service` modules to remain distribution-agnostic. Adjust `ovn_central_packages` and `ovn_central_services` to match your platform.
