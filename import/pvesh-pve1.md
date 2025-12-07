# pvesh — Features and usage for pve1

Overview
- Target host: pve1 (172.16.10.20)
- Proxmox VE version targeted by these playbooks/docs: 9.1.1
- SDN packages present on `pve1`: openvswitch-switch, ovn-common, ovn-host, ovn-central

Primary pvesh endpoints used
- Node network (per-node network interfaces and bridges)
  - `GET /nodes/{node}/network` — list interfaces (use `--output-format json`)
  - `CREATE /nodes/{node}/network` — create interfaces/bridges (bridge, vlan, etc.)
  - `SET /nodes/{node}/network` — apply pending network changes
  - `DELETE /nodes/{node}/network/{iface}` — remove interface

- Cluster SDN objects (cluster-wide — fabrics, controllers, zones, vnets, subnets)
  - `GET /cluster/sdn` — cluster SDN overview
  - `GET /cluster/sdn/fabrics`, `CREATE /cluster/sdn/fabrics/fabric`, `SET /cluster/sdn`
  - `GET /cluster/sdn/controllers`, `CREATE /cluster/sdn/controllers`
  - `GET /cluster/sdn/zones`, `CREATE /cluster/sdn/zones`
  - `GET /cluster/sdn/vnets`, `CREATE /cluster/sdn/vnets`
  - `GET /cluster/sdn/subnets`, `CREATE /cluster/sdn/subnets`

Common commands / examples
- Show node networks (JSON):
  pvesh get /nodes/localhost/network --output-format json

- Create VLAN-aware bridge (example):
  pvesh create /nodes/localhost/network -type bridge -bridge_ports "eth1" -bridge_vlan_aware yes -autostart yes

- Apply pending network changes (important — GUI shows "Pending changes" until run):
  pvesh set /nodes/localhost/network

- Show cluster SDN controllers / zones / vnets (JSON):
  pvesh get /cluster/sdn/controllers --output-format json
  pvesh get /cluster/sdn/zones --output-format json
  pvesh get /cluster/sdn/vnets --output-format json

Ansible patterns used in this repo
- Commands are executed via `ansible.builtin.command` with `--output-format json`, parsing stdout with `from_json`.
- Use `delegate_to: localhost` for pvesh invocations that target the Proxmox API from the control machine.
- Typical flow in playbooks/roles:
  1. `pvesh get` to read current state
  2. `pvesh create` to add objects (bridges, sdn objects)
  3. `pvesh set` to apply file-backed or cluster-wide changes
  4. verify with `pvesh get` and OS checks (`ip link`, `ovs-vsctl`)

Verification and troubleshooting
- Use `pvesh get /nodes/localhost/network` and `jq` filters to find specific `vmbr*` interfaces.
- If bridges appear as "Pending changes" in the GUI, run `pvesh set /nodes/localhost/network`.
- Combine `pvesh get` checks with `ip link show` and `ovs-vsctl show` to confirm kernel-level state.

Host-specific notes for `pve1`
- IP / inventory: `pve1.comwell.edgesec.ca` → 172.16.10.20 (see `inventory` and `host_vars`).
- repo playbooks already target `pve1` by default (many examples use `-e target=pve1.comwell.edgesec.ca`).
- SDN packages (OVS/OVN) are present on `pve1`; roles assume `pvesh` is available and that SDN config may be managed cluster-wide under `/cluster/sdn`.

Next actions / live checks (optional)
- SSH to `root@172.16.10.20` and run these live checks:
  - `pvesh get /nodes/localhost/network --output-format json`
  - `pvesh get /cluster/sdn --output-format json`
  - `pvesh get /cluster/sdn/controllers --output-format json`
- If you want, I can run these live (requires SSH access) and capture outputs into examples in this doc.

References in this repo
- `docs/contributing.md` — detailed pvesh SDN commands and patterns
- `roles/sdn_fabric_provision` and `roles/vxlan` — concrete pvesh usage examples (create/set/get)
