# prereqs role

Installs common prerequisites for Proxmox hosts used by the `nic_pinning` and `provision` roles.

What it does

- Installs packages listed in `roles/prereqs/defaults/main.yml` (git, make, ethtool, lm-sensors, wget by default).
- Optionally downloads and places `proxmox-network-interface-pinning` at `/usr/local/bin/` when `pve_network_interface_pinning_url` is provided.

Usage

Add this role before `nic_pinning` in your playbook. Example in the provision playbook:

```yaml
- hosts: proxmox-hosts
  become: true
  roles:
    - prereqs
    - nic_pinning
    - provision
```

Notes

- This role currently targets Debian/Ubuntu via `apt` tasks. If you need CentOS/RHEL support, I can add conditional tasks for `yum`/`dnf`.
- To auto-download the pve-network-interface-pinning script, set the variable `pve_network_interface_pinning_url` to the script's URL.
