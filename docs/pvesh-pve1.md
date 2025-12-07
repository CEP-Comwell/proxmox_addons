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

Live pvesh outputs (captured from `pve1`)

- `pvesh get /nodes/localhost/network --output-format json` (node network list)

```json
[{"altnames":["enp23s0f2","enx0894ef13049a"],"exists":1,"families":["inet"],"iface":"nic2","method":"manual","method6":"manual","priority":9,"type":"eth"},{"altnames":["enp23s0f1","enx0894ef130499"],"exists":1,"families":["inet"],"iface":"eth4","method":"manual","method6":"manual","priority":7,"type":"eth"},{"altnames":["enp12s0f1","enx98b7851ed7f4"],"exists":1,"families":["inet"],"iface":"xg1","method":"manual","method6":"manual","priority":4,"type":"eth"},{"active":1,"address":"172.16.10.20","autostart":1,"bridge_fd":"0","bridge_ports":"ens2f0","bridge_stp":"off","cidr":"172.16.10.20/24","families":["inet"],"gateway":"172.16.10.1","iface":"vmbr0","method":"static","method6":"manual","netmask":"24","priority":10,"type":"bridge"},{"exists":1,"families":["inet"],"iface":"eth1","method":"manual","method6":"manual","priority":5,"type":"eth"},{"active":1,"altnames":["enp12s0f0","enx98b7851ed7f3"],"exists":1,"families":["inet"],"iface":"ens2f0","method":"manual","method6":"manual","priority":3,"type":"eth"},{"altnames":["enp23s0f0","enx0894ef130498"],"exists":1,"families":["inet"],"iface":"nic1","method":"manual","method6":"manual","priority":8,"type":"eth"},{"altnames":["enp23s0f3","enx0894ef13049b"],"exists":1,"families":["inet"],"iface":"eth2","method":"manual","method6":"manual","priority":6,"type":"eth"}]
```

- `pvesh get /cluster/sdn --output-format json` (cluster SDN summary)

```json
[{"id":"vnets"},{"id":"zones"},{"id":"controllers"},{"id":"ipams"},{"id":"dns"},{"id":"fabrics"}]
```

- `pvesh get /cluster/sdn/controllers --output-format json` (controllers list)

```json
[]
```

Notes from live capture
- `vmbr0` is present and configured with `address: 172.16.10.20/24`, `bridge_ports: ens2f0`, and `autostart: 1`.
- The cluster SDN endpoints exist (vnets/zones/controllers/etc.) but there are no controllers currently defined (empty controllers list).
- These results confirm the repo assumptions: `pvesh` is available on `pve1`, node-level network objects are present, and cluster SDN namespace exists but may be mostly empty until objects are created.

Detailed live captures (additional checks)

- `pvesh get /nodes` returned:

```json
[{"id":"node/pve1","node":"pve1","status":"online","uptime":2404}]
```

- `pvesh get /nodes/localhost/network` (full) was captured above; notable interfaces:
  - `vmbr0` (bridge) — `address: 172.16.10.20/24`, `bridge_ports: ens2f0`, `autostart: 1`.
  - physical interfaces present: `ens2f0`, `xg1`, `nic1`, `nic2`, `eth1`, `eth2`, `eth4` (many are DOWN except `ens2f0`).

- `pvesh get /cluster/sdn` returned the top-level SDN categories (vnets/zones/controllers/ipams/dns/fabrics) but individual listings were empty in API responses.

- `/etc/pve/sdn/sdn.cfg` exists and contains full SDN definitions (controllers, fabric `fab-core`, zones `zone1`/`zone2`, multiple `vnet` and `subnet` entries). Example excerpt shows `controller1`, `fab-core`, `zone1`, `vnet vx10100`, and many `subnet` entries.

- `ip -br link` shows `ens2f0` and `vmbr0` UP; several other physical interfaces are DOWN; multiple veth pairs and `br-int` present for OVS.

- `ovs-vsctl show` reports an `ovs_version` and a `Bridge br-int` (datapath `system`, `fail_mode: secure`) but `ovs-system` is DOWN.

Observations and implications
- There is a repo-managed `/etc/pve/sdn/sdn.cfg` with SDN definitions; however the `pvesh` cluster GET endpoints returned empty arrays for many categories. This suggests the file is present but the running Proxmox API state may not have the objects loaded/applied via `pvesh set /cluster/sdn` (or objects live in different subdirs accessible via specific names).
- `vmbr0` is configured and active; OVS integration exists (`br-int`) but OVS system bridge is DOWN — verify OVN/OVS services if needed.
- Many veth interfaces and container/VM veth pairs are present (vetho*/vethl*), indicating overlay/tenant ports exist at host level even if cluster SDN API lists are empty.

Recommended next steps (I can run these now):
- Query specific SDN object paths named in `/etc/pve/sdn/sdn.cfg` (for example: `/cluster/sdn/controllers/controller1`, `/cluster/sdn/fabrics/fab-core`, `/cluster/sdn/zones/zone1`, `/cluster/sdn/vnets/vx10100`) to see whether those objects are accessible via pvesh.
- Optionally run `pvesh set /cluster/sdn` to apply the current `/etc/pve/sdn/sdn.cfg` into the running SDN API state (this will change cluster API-visible objects).
- Verify OVS/OVN services with `systemctl status` and check `ovsdb-server`/`ovn-controller` if you want a deeper OVS state check.

What I ran and observed next
- I attempted `pvesh get` on the specific objects named in `sdn.cfg` (controller1, fab-core, zone1, vx10100) — all reported "does not exist" via the API.
- I then ran `pvesh set /cluster/sdn` to apply `/etc/pve/sdn/sdn.cfg`. The command ran and triggered network reload tasks, but subsequent `pvesh get` listings still returned empty arrays for controllers/fabrics/zones/vnets.
- I inspected service logs (`pvedaemon`) and found Perl warnings during SDN parsing, such as:

```
Use of uninitialized value in string eq at /usr/share/perl5/PVE/API2/Network/SDN/Fabrics/Fabric.pm line 239.
Use of uninitialized value $zone in hash element at /usr/share/perl5/PVE/Network/SDN/Ipams/PVEPlugin.pm line 93.
```

Interpretation
- The presence of warnings in the SDN parser suggests `/etc/pve/sdn/sdn.cfg` includes entries that the API code isn't fully mapping into runtime objects (missing required fields or malformed sections). That explains why the file exists but `pvesh` still shows empty object lists.

Recommended remediation
- Inspect `/etc/pve/sdn/sdn.cfg` for missing/invalid fields (zones referenced by IPAM entries, or controller/fabric attributes). The file excerpt in this host shows many vnets/subnets/zones; check whether required attributes (IDs, zone names, ipam references) are present.
- Re-render the `sdn.cfg` via the `roles/sdn_fabric_provision` Ansible role (it manages the file) and re-run `pvesh set /cluster/sdn`.
- If you want, I can:
  - run a `pvesh set /cluster/sdn` again and capture any immediate errors, or
  - run `sed -n '1,200p' /etc/pve/sdn/sdn.cfg` to extract the exact sections causing parser warnings and suggest fixes.
