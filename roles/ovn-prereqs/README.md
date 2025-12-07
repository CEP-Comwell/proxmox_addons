OVN prerequisites role
======================

This role installs packages required to run OVN on Debian/Proxmox and optionally stops/masks distribution-provided OVN systemd units so an independent OVN stack may be used.

Variables (defaults in `defaults/main.yml`):
- `apt_update` (bool) — run `apt update` before install
- `ovn_prereq_packages` (list) — packages to install (default includes `openvswitch-switch`, `ovn-central`, `ovn-common`, `ovn-host`, `python3-openvswitch`)
- `mask_ovn_systemd_units` (bool) — stop and mask distro OVN units
- `ovn_distro_units` (list) — systemd unit names to stop/mask

Usage example (playbook):

```yaml
- hosts: pve1
  become: true
  roles:
    - role: ovn-prereqs
      vars:
        apt_update: true
        mask_ovn_systemd_units: true
```
