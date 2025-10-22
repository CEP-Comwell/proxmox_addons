# Provision role

Automates the creation and assignment of bridges on Proxmox nodes using a safe generate/edit/apply workflow.

This README documents the current workflow and variables. Older/duplicated instructions have been removed — the playbook `edgesec-sdn/playbooks/provision.yml` runs `nic_pinning` followed by `provision` to normalize names and then apply bridge assignments.

## Overview

The intended workflow is:

1. Run `nic_pinning` to normalize/pin network device names (the playbook runs this automatically).
2. Inspect and edit the generated provision template (it contains detected interfaces and suggested bridge assignments).
3. Run `provision` to apply the edited template (with optional confirmation and preferred-MAC override).

This file contains examples and variable references below.

## Workflow details

- Step 1: Normalize / pin NIC names

  - `nic_pinning` will call `pve-network-interface-pinning` to create persistent systemd `.link` files (MAC-based pinning). This makes interface names deterministic across reboots.
  - `nic_pinning` also emits a suggested provision template at the path defined by `provision_template_path`.

- Step 2: Inspect and edit

  - The template (default `/tmp/provision_nic_assignments-{{ inventory_hostname }}.yml`) contains three sections: `detected_interfaces`, `bridges`, and `bridge_assignments`.
  - Edit `bridge_assignments` to map normalized interface names (e.g. `xg1`, `eth1`, `nic2`) to your desired bridges.

Important: the role protects the interface currently enslaved to `vmbr0` (the Proxmox web management interface). The `nic_pinning` role detects this interface and the generated template includes `protected_management_interface` and `protected_management_mac`. `provision` will refuse to reassign or change that interface — remove it from `bridge_assignments` if you accidentally included it and re-run.

- Step 3: Apply

  - Run `provision`. The role validates the template, optionally honors `provision_preferred_mgmt_mac` or `provision_preferred_mgmt_name`, and maps normalized names back to kernel interface names before applying.
  - Applying assignments will briefly bring interfaces down while they are enslaved to bridges — expect transient network interruption.

## Variables (defaults in `roles/provision/defaults/main.yml`)

- `mgmt_bridge`: mgmt bridge name (default `vmbr99`)
- `vm_bridge`: VM/data bridge name (default `vmbr1`)
- `ext_bridge`: external bridge name (default `vmbr2`)
- `provision_template_path`: path to rendered template (default `/tmp/provision_nic_assignments-<inventory_hostname>.yml`)
- `provision_generate_only`: when true, render template but do not apply (default `false`)
- `provision_preferred_mgmt_mac`: optional MAC to force mgmt selection (default `null`)
- `provision_preferred_mgmt_name`: optional kernel interface name to force mgmt selection (default `null`)
- `provision_confirm_before_apply`: pause for confirmation before applying (default `false`)

## Examples

Generate a template without making changes:

```bash
ansible-playbook -i inventory.yml edgesec-sdn/playbooks/provision.yml \
  --limit pve-node1 \
  -e provision_generate_only=true
```

Edit `/tmp/provision_nic_assignments-pve-node1.yml`, then apply specifying the template and forcing mgmt by MAC:

```bash
ansible-playbook -i inventory.yml edgesec-sdn/playbooks/provision.yml \
  --limit pve-node1 \
  -e provision_template_path=/tmp/provision_nic_assignments-pve-node1.yml \
  -e provision_preferred_mgmt_mac=aa:bb:cc:dd:ee:ff
```

Apply but pause for confirmation before making network changes:

```bash
ansible-playbook -i inventory.yml edgesec-sdn/playbooks/provision.yml \
  --limit pve-node1 \
  -e provision_template_path=/tmp/provision_nic_assignments-pve-node1.yml \
  -e provision_confirm_before_apply=true
```

## One-shot interactive workflow

If you'd like a guided generate/edit/apply flow that opens the generated template in your local $EDITOR, use the wrapper playbook `edgesec-sdn/playbooks/provision_workflow.yml`.

Example (will run `nic_pinning`, fetch the template to the control node, open your editor, then push back and run `provision`):

```bash
ansible-playbook -i inventory.yml edgesec-sdn/playbooks/provision_workflow.yml --limit pve-node1
```

Notes:
- The wrapper fetches the template to `./fetched_templates/<host>.yml` on the control node.
- It opens the file with `$EDITOR` (falls back to `vi`).
- After you save and exit, the edited file is pushed back to the target and `provision` runs.

## Troubleshooting

- If the play fails with "Template contains interfaces not present on host", open the template and compare `bridge_assignments` entries to the `detected_interfaces` list at the top of the file.
- To inspect normalized names and `.link` files created by `nic_pinning`, check `/etc/systemd/network/` and the file emitted by `nic_pinning`.

## Contributing

See the [root contributing guide](../../docs/contributing.md) and `docs/role_readme_template.md` for the role README checklist.
