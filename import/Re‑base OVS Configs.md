
# Meta‑Prompt (Updated): Prepare **Offline NetBox YAML IPAM** & Re‑base OVS/Proxmox Configs to the Latest Mermaid Topology

> **Goal**: Have a code‑capable LLM produce **version‑controlled YAML files** (NetBox‑compatible) and supporting artifacts **without deploying NetBox yet**.  
> These files become the **source of truth** for IPAM, EVPN/RTs, and SDN metadata. Later, we’ll import them into NetBox and implement the separate **“Flow‑Programmed VXLAN for Proxmox/OVS (Ansible + Hook)”** meta‑prompt.

---

## 0) Inputs & Policies (must honor)

- **Topology (from the latest Mermaid diagram)**  
  - Bridges: `vmbr1` (OVS, tenant/services), `vmbr99` (OVS, management), `vmbr2` (Linux bridge, gateway/edge).  
  - veth glue: `vmbr1↔vmbr2`, `vmbr99↔vmbr2` to avoid VyOS hairpin for **local** traffic.  
  - VyOS acts as EVPN RR/Gateway; FRR on Proxmox peers via BGP EVPN.

- **Flow‑Programmed VXLAN invariants** (to be used later)  
  - OVS VXLAN ports use: `options:remote_ip=flow`, `options:key=flow`, `options:dst_port=4789`, `options:nolearning=true`, `options:csum=true`, **`options:local_ip=<per-bridge>`**.  
  - Egress flows will set **`tun_id=<VNI>`** and **`tun_dst=<peer>`**; ingress flows match `tun_id` → `NORMAL`.

- **Per‑bridge local IPs** (pinned as VTEP source)  
  - `vmbr1 → local_ip=10.255.0.1`  
  - `vmbr99 → local_ip=10.255.0.99`  
  - `vmbr2 → local_ip=10.255.0.2`

- **Fallback `tun_dst` map** (hook uses when EVPN next‑hop isn’t ready)  
  - `TUN_DST_vmbr1=10.255.0.2`  
  - `TUN_DST_vmbr2=172.16.0.2`  
  - `TUN_DST_vmbr99=<peer-ip-for-core-services>`

- **MTU policy**  
  - `vmbr1`, `vmbr99` & their VXLAN ports: **MTU 9000**  
  - `vmbr2` and any VXLAN ports bound to WG/edge: **MTU 1420**

- **Proxmox SDN**: Zones/VNets are **metadata only**; **do not** auto‑create VXLAN ports. Ansible owns OVS dataplane.

- **Port names**: ≤ **8 characters** (Proxmox 9.1 GUI limiter).

- **Day‑2 reloads**: No reload unless `perform_reload=true`; then atomic + logged.

---

## 1) Deliverables (offline, NetBox‑intent YAML + helpers)

1. **YAML: NetBox objects**
   - `netbox-vrfs.yml` — VRFs with optional RD and import/export RTs.
   - `netbox-route-targets.yml` — Route Targets (`ASN:number`) used by EVPN.
   - `netbox-prefixes.yml` — IPAM prefixes with **custom‑fields** (cf) that carry VNI/VNet/bridge/MTU/export policy/etc.
   - `netbox-custom-fields.yml` — Custom fields definitions for Prefix (or VRF).
   - `netbox-vlans.yml` *(optional)* — VLANs/VLAN groups if you track L2 domains.

2. **Derived, deploy‑agnostic artefacts**
   - `ovs_vxlan_ports.yml` — port list derived from prefixes (bridge + `cf.vni`, names ≤ 8).
   - `/etc/pve/vni-map.conf` — VMID.netX → VNI (seed with current 200/201/202 mapping).
   - `/etc/pve/tun-dst-map.conf` — `TUN_DST_<bridge>=<ip>` entries.

3. **Offline validation scripts** (no NetBox required)
   - `validate_ipam.py` — checks: VNI uniqueness, `vnet == 'vn' + VNI`, **gateway ∈ subnet**, **DHCP range ⊂ subnet**, MTU profile consistent with bridge.

4. **Future import stub** (used later when NetBox is deployed)
   - `import_to_netbox.py` — idempotently creates RTs, VRFs, Prefixes, sets custom fields via `pynetbox`.

5. **Repo layout**
