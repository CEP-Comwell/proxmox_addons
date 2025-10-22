
# nic_pinning role — interface pinning and mapping

This role normalizes (pins) network interface names on Proxmox hosts and emits a suggested `provision` assignment template that you can edit and apply. It uses `pve-network-interface-pinning` to generate systemd `.link` files (MAC-based pinning) and creates a sane default mapping for use by the `provision` role.

## Contents

- Key behaviors
- Outputs / artifacts
- Installation / prerequisites
- Usage examples
- Management interface protection
- Troubleshooting and troubleshooting commands (copy-paste)
- Optional NetBox export
- Contributing

## Key behaviors

- Detect physical kernel network interfaces and classify them by type (10G vs ethernet vs other).
- Generate normalized names (for example `xg1`, `eth1`, `nic2`) using ordering heuristics.
- Call `pve-network-interface-pinning` to generate persistent `.link` files to pin names by MAC.
- Detect and protect the interface currently enslaved to `vmbr0` (Proxmox management) and exclude it from automatic re-assignment.
- Emit a suggested `provision` template at `provision_template_path` (default `/tmp/provision_nic_assignments-<inventory_hostname>.yml`) which `provision` can load and apply.

## Outputs / artifacts

- systemd `.link` files under `/etc/systemd/network/` (or `/usr/local/lib/systemd/network`) — created by the `pve-network-interface-pinning` tool and optionally by the role.
- A suggested provision template file containing:
  - `detected_interfaces`: list of kernel interface names discovered
  - `protected_management_interface` and `protected_management_mac` (if vmbr0 is present)
  - `bridges`: suggested bridge names
  - `bridge_assignments`: suggested mapping using normalized names

## Installation / prerequisites

### Using the provided `prereqs` role

We provide a small `prereqs` role (`roles/prereqs`) that installs common packages (`git`, `ethtool`, `lm-sensors`, `wget`) and can optionally download `pve-network-interface-pinning` for you. To use it, add `prereqs` as the first role in your play.

### Manual install

If you prefer to install the script manually on a node, place the executable at `/usr/local/bin/pve-network-interface-pinning` and make it executable (`chmod +x`). The `nic_pinning` role will call it when present.

## Usage examples

### Run only `nic_pinning` to pin names and generate the suggestion file

```bash
ansible-playbook -i inventory.yml edgesec-sdn/playbooks/provision.yml -t nic_pinning --limit pve-node1
```

### Interactive wrapper (generate -> edit -> apply)

```bash
ansible-playbook -i inventory.yml edgesec-sdn/playbooks/provision_workflow.yml --limit pve-node1
```

### After editing the generated template, run `provision` to apply assignments

```bash
ansible-playbook -i inventory.yml edgesec-sdn/playbooks/provision.yml --limit pve-node1 -e provision_template_path=/tmp/provision_nic_assignments-pve-node1.yml
```

## Management interface protection

By default the role detects any interface currently attached to `vmbr0` and marks it as `protected_management_interface`. The generated template will show this value. The `provision` role will refuse to reassign that interface and will not modify it — this prevents accidental loss of connectivity to the Proxmox management interface.

If you absolutely need to change the management interface, do so manually and only after ensuring access via an out-of-band console or having a plan to re-establish connectivity.

### Recommendation for installation

When installing Proxmox, pick a single, permanent NIC to be the management interface (the one bound to `vmbr0`). Choosing a predictable NIC at install time (for example a port that your operations team will always keep on the management VLAN) avoids accidental reconfiguration later and simplifies automation.

### Operational note about routing/gateway

If you must change which physical port provides management later, it's normal to update the default gateway or upstream router configuration on the network side to point to the new management-facing switch port or VLAN. Doing the NIC change and updating the upstream gateway is a standard network operation — just ensure you have console access or an alternate path to the node while making the change so you don't lose remote management access.

## Tiny safety checklist (quick before-you-change)

1. Ensure console access: have IPMI/iLO/serial or physical console available before making changes.
2. Capture current state: save `/etc/network/interfaces`, `/etc/systemd/network/*.link`, and note `ip addr` / `ip route` output.
3. Generate the provision template and review `protected_management_interface` so you know which NIC is currently used by vmbr0.
4. If changing the mgmt port, pre-stage the new bridge/interface config (edit the provision template) but do not apply yet.
5. Apply during a maintenance window and be prepared to use the console to restore the old configuration if necessary.
6. After the change, verify management plane reachability and update upstream gateway/switch configuration if required.

## Troubleshooting — quick commands

Below are copy-paste command examples you can use on a Proxmox node to inspect and troubleshoot interface pinning and renaming.

### 1) Check the `pve-network-interface-pinning` binary and help

```bash
which proxmox-network-interface-pinning || echo "not installed"
proxmox-network-interface-pinning --help
```

### 2) Generate a `.link` file for an interface (dry-run or test)

# (run on the target; the tool will create `/usr/local/lib/systemd/network/10-<name>.link`)
```bash
proxmox-network-interface-pinning generate --interface enp3s0 --target-name eth1
ls -l /usr/local/lib/systemd/network/10-eth1.link
```

### 3) Inspect `.link` files and systemd-networkd pointers

```bash
ls -l /etc/systemd/network /usr/local/lib/systemd/network
readlink -f /sys/class/net/eth1/master || true
```

### 4) Check kernel interface MACs and current masters

```bash
ip -br link show
for i in $(ls -1 /sys/class/net | grep -v lo); do echo "--- $i ---"; cat /sys/class/net/$i/address; readlink -f /sys/class/net/$i/master || true; done
```

### 5) Check ethtool for link speed and capabilities

```bash
ethtool enp3s0 | sed -n '1,40p'
```

### 6) Reload systemd and restart networking after adding .link files

```bash
systemctl daemon-reload
systemctl restart systemd-networkd || systemctl restart networking
```

### 7) If names didn't change as expected, check for conflicting .link files

```bash
grep -R "Name=" /etc/systemd/network /usr/local/lib/systemd/network || true
```

## Optional: export mappings to NetBox

If you manage your inventory and interfaces in NetBox, it's useful to store the generated mapping (normalized name → kernel name → MAC) against the corresponding Proxmox device. Below is a suggested workflow and a small template is included in this role to generate a NetBox-friendly export.

Suggested workflow

1. After running `nic_pinning`, fetch the mapping file (the wrapper writes `./fetched_templates/<host>.yml`) or render the template using Ansible facts.
2. Use the included template `roles/nic_pinning/templates/netbox_export.j2` to render a JSON/YAML payload containing:
   - device name (inventory hostname)
   - interfaces: list of { name, kernel_name, mac, normalized_name }
3. Upload the payload to NetBox via its API (pynetbox or curl). Example curl snippet:

```bash
curl -X POST "https://<netbox>/api/dcim/interfaces/" \
  -H "Authorization: Token <NETBOX_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '@./fetched_templates/<host>-netbox.json'
```

Note: you may prefer to use pynetbox to create Interface objects and attach custom fields for the normalized name.

Template

The role includes `roles/nic_pinning/templates/netbox_export.j2` which renders a JSON structure suitable for NetBox import or a small Python/pynetbox script to consume. Customize fields to match your NetBox schema (custom fields, device roles, etc.).

## Contributing

See the [root contributing guide](../../docs/contributing.md) and `docs/role_readme_template.md` for role README conventions and checklist.

## Optional: export mappings to NetBox

If you manage your inventory and interfaces in NetBox, it's useful to store the generated mapping (normalized name → kernel name → MAC) against the corresponding Proxmox device. Below is a suggested workflow and a small template is included in this role to generate a NetBox-friendly export.

Suggested workflow

1. After running `nic_pinning`, fetch the mapping file (the wrapper writes `./fetched_templates/<host>.yml`) or render the template using Ansible facts.
2. Use the included template `roles/nic_pinning/templates/netbox_export.j2` to render a JSON/YAML payload containing:
   - device name (inventory hostname)
   - interfaces: list of { name, kernel_name, mac, normalized_name }
3. Upload the payload to NetBox via its API (pynetbox or curl). Example curl snippet:

```bash
curl -X POST "https://<netbox>/api/dcim/interfaces/" \
  -H "Authorization: Token <NETBOX_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '@./fetched_templates/<host>-netbox.json'
```

Note: you may prefer to use pynetbox to create Interface objects and attach custom fields for the normalized name.

Template

The role includes `roles/nic_pinning/templates/netbox_export.j2` which renders a JSON structure suitable for NetBox import or a small Python/pynetbox script to consume. Customize fields to match your NetBox schema (custom fields, device roles, etc.).
