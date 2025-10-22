# nic_pinning role

This role normalizes (pins) network interface names on Proxmox hosts and emits a suggested `provision` assignment template that you can edit and apply. It uses `pve-network-interface-pinning` to generate systemd `.link` files (MAC-based pinning) and creates a sane default mapping for use by the `provision` role.

Key behaviors
- Detects physical kernel network interfaces and classifies them by type (10G vs ethernet vs other).
- Generates normalized names (for example `xg1`, `eth1`, `nic2`) using ordering heuristics.
- Calls `pve-network-interface-pinning` to generate persistent `.link` files to pin names by MAC.
- Detects and protects the interface currently enslaved to `vmbr0` (Proxmox management) and excludes it from automatic re-assignment.
- Emits a suggested `provision` template at `provision_template_path` (default `/tmp/provision_nic_assignments-<inventory_hostname>.yml`) which `provision` can load and apply.

Outputs / artifacts
- systemd `.link` files under `/etc/systemd/network/` (or `/usr/local/lib/systemd/network`) — created by the `pve-network-interface-pinning` tool and optionally by the role.
- A suggested provision template file containing:
  - `detected_interfaces`: list of kernel interface names discovered
  - `protected_management_interface` and `protected_management_mac` (if vmbr0 is present)
  - `bridges`: suggested bridge names
  - `bridge_assignments`: suggested mapping using normalized names

Variables and integration points
- The role respects the `provision_template_path` variable so it writes the suggestion where `provision` will look for it. Default is configured in `roles/provision/defaults/main.yml`.
- If you use the combined playbook `edgesec-sdn/playbooks/provision.yml`, `nic_pinning` runs before `provision` and produces the template `provision` will load.

Usage examples

1) Run only nic_pinning to pin names and generate the suggestion file:

```bash
ansible-playbook -i inventory.yml edgesec-sdn/playbooks/provision.yml -t nic_pinning --limit pve-node1
```

2) Use the wrapper workflow (recommended for single-host interactive flow):

```bash
ansible-playbook -i inventory.yml edgesec-sdn/playbooks/provision_workflow.yml --limit pve-node1
```

3) After editing the generated template, run the provision role to apply assignments:

```bash
ansible-playbook -i inventory.yml edgesec-sdn/playbooks/provision.yml --limit pve-node1 -e provision_template_path=/tmp/provision_nic_assignments-pve-node1.yml
```

Important: protection for Proxmox management NIC

By default the role detects any interface currently attached to `vmbr0` and marks it as `protected_management_interface`. The generated template will show this value. The `provision` role will refuse to reassign that interface and will not modify it — this prevents accidental loss of connectivity to the Proxmox management interface.

If you absolutely need to change the management interface, do so manually and only after ensuring access via an out-of-band console or having a plan to re-establish connectivity.

Recommendation for installation

When installing Proxmox, pick a single, permanent NIC to be the management interface (the one bound to `vmbr0`). Choosing a predictable NIC at install time (for example a port that your operations team will always keep on the management VLAN) avoids accidental reconfiguration later and simplifies automation.

Operational note about routing/gateway

If you must change which physical port provides management later, it's normal to update the default gateway or upstream router configuration on the network side to point to the new management-facing switch port or VLAN. Doing the NIC change and updating the upstream gateway is a standard network operation — just ensure you have console access or an alternate path to the node while making the change so you don't lose remote management access.

Tiny safety checklist (quick before-you-change)

1. Ensure console access: have IPMI/iLO/serial or physical console available before making changes.
2. Capture current state: save `/etc/network/interfaces`, `/etc/systemd/network/*.link`, and note `ip addr` / `ip route` output.
3. Generate the provision template and review `protected_management_interface` so you know which NIC is currently used by vmbr0.
4. If changing the mgmt port, pre-stage the new bridge/interface config (edit the provision template) but do not apply yet.
5. Apply during a maintenance window and be prepared to use the console to restore the old configuration if necessary.
6. After the change, verify management plane reachability and update upstream gateway/switch configuration if required.


Troubleshooting
- If pinning does not produce the expected normalized name, inspect the `.link` files under `/etc/systemd/network/` and the output of the `pve-network-interface-pinning` command.
- If `provision` refuses to apply because the template contains a `protected_management_interface`, remove that entry from `bridge_assignments` and re-run.

Contributing

See the [root contributing guide](../../docs/contributing.md) and `docs/role_readme_template.md` for role README conventions and checklist.
