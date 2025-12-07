OVN localnet fix role
=====================

This role enforces Open vSwitch -> OVN service ordering, provides a small cleanup
script to remove known stale network devices and prints a short version check.

Usage:

- Include the role in a playbook (see `playbooks/ovn_localnet_fix.yml`).
- Set `ovn_stale_devices` to a space-separated list of device names to delete
  if they exist and are NOT managed by OVS (e.g. `uplink-v11`).

Example:

ansible-playbook -i inventory playbooks/ovn_localnet_fix.yml -e "ovn_stale_devices='uplink-v11'"
