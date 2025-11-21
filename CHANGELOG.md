# Changelog

All notable changes to this project will be documented in this file.

## Unreleased
- Prefer `pvesh` for Linux bridge and subinterface provisioning where possible.
- Tighten fallback gating so `/etc/network/interfaces.d/*.cfg` files are only written when:
  - `write_interfaces_file=true`, and
  - `pve_node_id` is resolved, and
  - Ansible is not running in check mode.
- Harden pvesh parameter assembly to avoid passing empty bare flags (use `--flag=value`).
- Add asserts to validate interface/subinterface names for Proxmox API compatibility.
- Add a minimal CI workflow to run `ansible-playbook --syntax-check` on the main provisioning playbook.
