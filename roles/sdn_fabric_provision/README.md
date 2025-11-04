# Role: sdn_fabric_provision

This role provisions Proxmox SDN fabric, VNETs, subnets, and ports using the Proxmox API (`pvesh`). It is idempotent and will never modify or delete the management bridge (`vmbr0`).

## Usage

Add this role to your playbook after `network_provision`:

```yaml
roles:
  - prereqs
  - network_provision
  - sdn_fabric_provision
```

## Required Variables

Define these variables in a vars file (e.g., `vars/sdn_fabric.yml`), group_vars, or pass with `-e`:

```yaml
sdn_asn: 65010
sdn_peers: "10.0.0.1,10.0.0.2"
sdn_zone_name: evpn-core
sdn_fabric_name: fab-core
sdn_fabric:
  type: evpn
  controller: controller1
  nodes:
    - pve-node1
    - pve-node2
  extra:
    mtu: 1500
sdn_fabric_api:
  protocol: openfabric
  ip_prefix: 10.255.0.0/16
  ip6_prefix: fd00::/48
sdn_fabric_nodes:
  - node_id: pve-node1
    protocol: openfabric
    ip: 10.255.0.11
    ip6: fd00::11
  - node_id: pve-node2
    protocol: openfabric
    ip: 10.255.0.12
    ip6: fd00::12
sdn_l3vni: 65001
sdn_anycast_mac: "02:99:99:99:99:01"
sdn_zone_nodes:
  - pve-node1
  - pve-node2
sdn_zone_mtu: 1450
sdn_vni_plan:
  - name: vx10100
    vni: 10100
    cidr: 10.101.0.0/24
    gw: 10.101.0.1
    bridge: vmbr99
  - name: vx10101
    vni: 10101
    cidr: 10.101.1.0/24
    gw: 10.101.1.1
    bridge: vmbr99
  - name: vx10102
    vni: 10102
    cidr: 10.101.2.0/24
    gw: 10.101.2.1
    bridge: vmbr99
  - name: vx10031
    vni: 10031
    cidr: 10.10.31.0/24
    gw: 10.10.31.1
    bridge: vmbr99
  - name: vx10032
    vni: 10032
    cidr: 10.10.32.0/24
    gw: 10.10.32.1
    bridge: vmbr99
  - name: vx10110
    vni: 10110
    cidr: 10.110.10.0/24
    gw: 10.110.10.1
    bridge: vmbr1
  - name: vx9000
    vni: 9000
    cidr: 10.90.0.0/24
    gw: 10.90.0.1
    bridge: vmbr1
  - name: vx9006
    vni: 9006
    cidr: 10.90.6.0/24
    gw: 10.90.6.1
    bridge: vmbr1
  - name: vx9003
    vni: 9003
    cidr: 10.90.3.0/24
    gw: 10.90.3.1
    bridge: vmbr2
  - name: vx10120
    vni: 10120
    cidr: 10.120.10.0/24
    gw: 10.120.10.1
    bridge: vmbr2
sdn_extra_config: |
  fabric fabric1 {
      type evpn
      controller controller1
  }
  # Add more VNETs as needed
sdn_manage_config_file: true
```

## Using group_vars/all.yml

It is recommended to place your SDN/EVPN variables in `group_vars/all.yml` for cluster-wide use. Example:

```yaml
# group_vars/all.yml
# ...existing variables...
# --- SDN/EVPN fabric variables for sdn_fabric_provision ---
sdn_asn: 65010
sdn_peers: "10.0.0.1,10.0.0.2"
sdn_zone_name: evpn-core
sdn_fabric_name: fab-core
sdn_fabric_api:
  protocol: openfabric
  ip_prefix: 10.255.0.0/16
  ip6_prefix: fd00::/48
sdn_fabric_nodes:
  - node_id: pve-node1
    protocol: openfabric
    ip: 10.255.0.11
    ip6: fd00::11
  - node_id: pve-node2
    protocol: openfabric
    ip: 10.255.0.12
    ip6: fd00::12
sdn_l3vni: 65001
sdn_anycast_mac: "02:99:99:99:99:01"
sdn_zone_mtu: 1450
sdn_vni_plan:
  - name: vx10100
    vni: 10100
    cidr: 10.101.0.0/24
    gw: 10.101.0.1
    bridge: vmbr99
  - name: vx10101
    vni: 10101
    cidr: 10.101.1.0/24
    gw: 10.101.1.1
    bridge: vmbr99
  - name: vx10102
    vni: 10102
    cidr: 10.101.2.0/24
    gw: 10.101.2.1
    bridge: vmbr99
  - name: vx10031
    vni: 10031
    cidr: 10.10.31.0/24
    gw: 10.10.31.1
    bridge: vmbr99
  - name: vx10032
    vni: 10032
    cidr: 10.10.32.0/24
    gw: 10.10.32.1
    bridge: vmbr99
  - name: vx10110
    vni: 10110
    cidr: 10.110.10.0/24
    gw: 10.110.10.1
    bridge: vmbr1
  - name: vx9000
    vni: 9000
    cidr: 10.90.0.0/24
    gw: 10.90.0.1
    bridge: vmbr1
  - name: vx9006
    vni: 9006
    cidr: 10.90.6.0/24
    gw: 10.90.6.1
    bridge: vmbr1
  - name: vx9003
    vni: 9003
    cidr: 10.90.3.0/24
    gw: 10.90.3.1
    bridge: vmbr2
  - name: vx10120
    vni: 10120
    cidr: 10.120.10.0/24
    gw: 10.120.10.1
    bridge: vmbr2
```

When these variables are present in `group_vars/all.yml`, you do not need to pass them with `-e` on the command line.

## Example Playbook Run

```bash
ansible-playbook -i ../../inventory provision.yml -e @vars/sdn_fabric.yml
```

## Notes
- The role will skip any VNETs/subnets targeting `vmbr0`.
- All SDN objects are created only if missing (idempotent).
- Extend `sdn_vni_plan` as needed for your topology.
- Requires `pvesh` to be available on the target nodes.
- When `sdn_manage_config_file` is `true`, the role templates `/etc/pve/sdn/sdn.cfg` and triggers `pvesh set /cluster/sdn` to apply changes cluster-wide. Set it to `false` if you prefer manual SDN config management.
- Use `sdn_fabric_nodes` to declare fabric members managed through `/cluster/sdn/fabrics/node`. The legacy `sdn_fabric.nodes` list still feeds the rendered `sdn.cfg` when you need the static stanza there, and `sdn_zone_nodes` controls zone membership. Additional fabric settings can be expressed via `sdn_fabric.extra`, and `sdn_extra_config` remains available for rare cases where raw snippets are still required.
- Set `sdn_fabric_node_purge: true` when you want automation to delete any fabric nodes that are not described in `sdn_fabric_nodes`.

## vmbr0 and Management Interface Exclusion

The `sdn_fabric_provision` role will automatically skip any VNET, subnet, or port creation for `vmbr0` (the management bridge) **or for the interface currently enslaved to vmbr0** (as detected by the `network_provision` role and exposed as the `protected_mgmt_iface` variable). You do **not** need to include VNETs or subnets for `vmbr0` or its interface in your `sdn_vni_plan` variable. This ensures that the management interface is never modified or affected by SDN automation.

**Best Practice:**
- Only specify VNETs/subnets for tenant, external, or SDN bridges (e.g., `vmbr1`, `vmbr2`, `vmbr99`) in your `sdn_vni_plan`.
- Let the role handle `vmbr0` and management interface exclusion automatically.

If you do include a VNET or subnet for `vmbr0` or the protected management interface in your `sdn_vni_plan`, the role will skip it and log a message, but it is not required for normal operation.

### Example: Skipping Management Bridge

If your `sdn_vni_plan` contains:

```yaml
sdn_vni_plan:
  - name: vxlan-mgmt
    vni: 10000
    cidr: 10.0.0.0/24
    gw: 10.0.0.1
    bridge: vmbr0
  - name: vxlan-tenant
    vni: 10110
    cidr: 10.110.10.0/24
    gw: 10.110.10.1
    bridge: vmbr1
```

The role will log a message and skip `vxlan-mgmt` (since it targets `vmbr0`), and only process `vxlan-tenant`.
