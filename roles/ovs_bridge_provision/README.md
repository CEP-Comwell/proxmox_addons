# Role: ovs_bridge_provision

Purpose
-------
This role is the single, authoritative writer for the persistent OVS block in
`/etc/network/interfaces`. It renders a deterministic, managed block (BEGIN/END)
from `ovs_bridges` data and inserts it atomically so the persistent file reflects
the operator-declared topology. Logical VXLAN names are recorded in each
bridge's `ovs_ports` line inside that managed block (so `ifreload`/boot shows
the intended configuration), while actual VXLAN devices are created dynamically
with `ovs-vsctl` under an operator gate (e.g. `ovs_create`).

Architectural note (condensed): use a single managed block in `/etc/network/interfaces` to persist the bridge
and `ovs_ports` mapping because the Proxmox API (`pvesh`) does not express the file-backed, boot-applied
mapping of logical VXLAN names into a bridge's `ovs_ports` line; persist names in the interfaces file and
manage runtime VXLAN devices with `ovs-vsctl` to keep persistence declarative and runtime operations idempotent.

- The API manages runtime objects/VM networking but lacks low-level, file-backed control to declare intended
  persistent mappings.
- A single managed block (BEGIN/END) is auditable, version-controllable, and prevents duplicate fragments.
- Separation of concerns (declarative persistence vs. operator-gated runtime instantiation) improves
  reproducibility, validation, and auditability.

When to use
-----------
- Use when you want a declarative, idempotent representation of OVS bridges for Proxmox hosts.
- Keep persistent configuration in version control and let this role render the file content.
- Preview the rendered block before applying by running the role with `write_interfaces_file: false`.

What it emits
-------------
- OVSPort stanzas for physical ports.
- OVSBridge stanzas for each OVS bridge including a single `ovs_ports` line.
- The template deduplicates and sorts ports for deterministic output.

Key variables (examples)
------------------------
These are the common variables the role reads or respects. Many are already defined in the play that
calls the role or in `host_vars`.

- `ovs_bridges` (list) - primary input list of bridge dicts. Typically provided via `host_vars/.../bridges.yml` or
  via a role var `bridges`. Each bridge should include at least `name` and `type`. Optional keys: `bridge_ports`/`ports`,
  `subinterfaces` (for vxlan names), `address`, `mtu`, `ovs_options`.

- `write_interfaces_file` (bool, default: false) - when true the rendered block will be inserted into
  `/etc/network/interfaces` (above `source /etc/network/interfaces.d/*`). When false, the role prints a preview using the
  `ovs_bridge_block` debug message.

- `ovs_create` (bool, default: false) - runtime gate for creating VXLAN devices. Set to true to allow runtime creation tasks
  (usually handled by a separate role, e.g. `ovs_vxlan_provision`).

- `force_ovsclean` (bool, default: false) - when true the role will remove Linux bridge stanzas for names that are now
  managed by OVS (use with caution).

- `perform_reload` (bool, default: false) - when true and `write_interfaces_file` is true, the role will run `ifquery` and
  then `ifreload -a` to apply changes on the host.

- `include_logical_ports_in_interfaces` (bool, default: false) - when true, vxlan subinterface names are included in the
  bridge's `ovs_ports` list in the persistent block.

Usage examples
--------------
1) Preview the rendered block (safe, no file write):

```bash
ansible-playbook -i inventory edgesec-sdn/playbooks/provision.yml \
  -e "inventory_hostname=pve1.comwell.edgesec.ca write_interfaces_file=false" --tags deploy_ovs_bridges
```

Or within a playbook, run the role with preview mode:

```yaml
- hosts: pve-nodes
  roles:
    - role: ovs_bridge_provision
      vars:
        write_interfaces_file: false
```

2) Write the persistent block (no reload):

```yaml
- hosts: pve-nodes
  roles:
    - role: ovs_bridge_provision
      vars:
        write_interfaces_file: true
        perform_reload: false
```

3) Write persistent block and reload network (operator-controlled):

```yaml
- hosts: pve-nodes
  roles:
    - role: ovs_bridge_provision
      vars:
        write_interfaces_file: true
        perform_reload: true
```

4) Create runtime VXLANs (separate role gates runtime actions):

```yaml
- hosts: pve-nodes
  roles:
    - role: ovs_bridge_provision
      vars:
        write_interfaces_file: true
    - role: ovs_vxlan_provision
      vars:
        ovs_create: true
        perform_reload: true
```

Integration notes
-----------------
- The role expects `ovs_bridges` to be populated from `host_vars/.../bridges.yml` or passed in as a role var.
- Bridge entries should set `type` to include `ovs` (case-insensitive) to be collected by this role; non-OVS bridges are ignored.
- The Jinja2 template `templates/ovs_bridges.j2` generates deterministic output (`unique | sort`) to minimize false changes.

Minimal host_vars example
-------------------------
Place under `host_vars/<hostname>/bridges.yml`:

```yaml
bridges:
  - name: vmbr99
    type: OVSBridge
    bridge_ports:
      - eth2
    mtu: 9000
    address: 10.255.0.99/28
    subinterfaces:
      - name: vx10031
        type: vxlan
        options:
          id: 10031
```

Troubleshooting
---------------
- If a bridge doesn't appear in the rendered block, ensure `bridges.yml` has the bridge with `name` and `type` containing `ovs`.
- If vxlan names are not included in `ovs_ports`, set `include_logical_ports_in_interfaces: true` and confirm each subinterface has `type: vxlan`.
- Use the role preview mode (`write_interfaces_file=false`) to inspect `ovs_bridge_block` without touching the host file.

Extending
---------
- Consider adding a short validation task (assert) before rendering to fail fast on malformed bridge entries.
- Optionally, add an Ansible debug task to log skipped non-OVS bridge entries to surface host_vars typos.

License & Maintainer
--------------------
This role is maintained as part of the edgesec proxmox_addons repository. Follow the repository license and contribution guidelines for changes.
