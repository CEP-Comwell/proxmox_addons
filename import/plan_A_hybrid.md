# Meta‑Prompt — **edgesec‑SDN Plan A (Hybrid)** with Clear Method Boundaries and Architectural Rationale
**Branch:** `fix/network-provision-pvesh-safety`  
**Audience:** AI coding assistant (Copilot/GPT‑5‑mini) implementing Ansible + Proxmox VE 9.x + OVS + FRR + VyOS RR

---

## 0) Intent & Guardrails (read first)
- **Do not use REST/HTTP/`uri`** for Proxmox. Use **`pvesh`** (Proxmox API CLI) and system tools only.
- **Honor the two methods explicitly:**
  - **`pvesh`** → Proxmox **node** networking objects (Linux `bridge/eth/vlan`, OVS `OVSBridge/OVSPort`) **and** **cluster SDN** (`zones/vnets/apply`).
  - **`ovs‑vsctl`** → **OVS‑only** operations (interface `mtu_request`, patch/glue ports, mirrors; optional non‑EVPN static vxlan).
- **Never attempt** node `/network type=vxlan`. VXLAN is **SDN‑driven** and renders as **Linux VXLAN + Linux VNet bridges** only after **Apply**.
- Respect safety flags and check mode:
  - `write_interfaces_file=false` → no writes to `/etc/network/interfaces*`.
  - `ovs_create=false` → no creation of OVS objects (discover/tune only).
  - `force_ovsclean=false` → no deletions.
  - `--check` → **no changes** (preflight `pvesh get`, print would‑be actions).

---

## 1) Architecture (Plan A, Hybrid) — **What we build and why**
**Roles of each layer (and rationale):**
- **`vmbr2` = Linux bridge (uplink toward VyOS RR)**  
  *Why Linux:* FRR (EVPN) integrates with **Linux networking constructs** via Netlink. The control‑plane (EVPN routes, MAC/IP learning, IRB) expects Linux VXLAN + bridges, not OVS tunnels. `vmbr2` is the clean L2/L3 handoff to the RR and the place to **clamp overlay MTU ≈ 1420** when WireGuard/NetBird is in path.  
  *Outcome:* Reliable FRR peering, correct MTU, predictable underlay.

- **`vmbr99` & `vmbr1` = OVS bridges (access layer)**  
  *Why OVS:* We want **VLAN‑aware switching**, **port mirroring**, and policy enforcement (Calico/eBPF) right at VM tap ports. OVS excels at edge features.  
  *Outcome:* VM traffic hits OVS capabilities while overlays are provided by Linux/SDN.

- **VXLAN/EVPN fabric is SDN‑driven at the cluster level**  
  *Why SDN:* Proxmox SDN is the supported way to declare **EVPN/VXLAN Zones/VNets** cluster‑wide. On **Apply**, Proxmox renders **Linux VXLAN devices + Linux VNet bridges** per node. This aligns with FRR’s expectations and gives us consistent, declarative overlays.  
  *Outcome:* All VNIs exist as Linux bridges/interfaces that FRR can bind to (SVIs/VRFs).

- **Glue (Linux → OVS) via veth/patch ports**  
  *Why glue:* OVS does not provide an EVPN control‑plane. We terminate VTEPs in Linux (SDN) and **bridge** them into OVS for VM access. The veth pair attaches one end to the Linux VNet bridge, the other to the OVS bridge.  
  *Outcome:* Traffic flows from overlays (Linux) into the OVS edge (features preserved).

- **Distributed IRB on Proxmox (SVIs on VNet bridges)**  
  *Why IRB locally:* Routing between VNIs on the same node should **not hairpin** to VyOS. By placing SVIs/VRFs on Linux VNet bridges, FRR routes east‑west locally and advertises prefixes via EVPN.  
  *Outcome:* Lower latency, better resilience, fast convergence.

- **VyOS FRR = Route Reflector + centralized policy**  
  *Why RR centralization:* Keep RT/RD policy, neighbor scaling, and site‑to‑site control cleanly centralized while **not** being the choke‑point for local inter‑VNI traffic.  
  *Outcome:* Scalable multi‑site EVPN with local IRB.

---

## 2) Method Boundaries — **What tool is used for each decision**
### Use **`pvesh`** when:
- **Declaring SDN overlays** (EVPN/VXLAN):
  - Add **Zone**: `pvesh create /cluster/sdn/zones --zone <id> --type evpn --peers <IPs>`
  - Add **VNets** (per VNI): `pvesh create /cluster/sdn/vnets --vnet vnet<VNI> --zone <id> --tag <VNI> --mtu <1420|9000>`
  - **Apply** overlays: `pvesh create /cluster/sdn/status/apply`  
  *(Reason: SDN owns VXLAN; FRR expects Linux VXLAN/bridges produced by Apply.)*
- **Creating node interfaces (Linux and OVS container objects)**:
  - Linux bridge/uplink: `pvesh create /nodes/<node>/network --type bridge|eth|vlan …`
  - OVS container objects: `pvesh create /nodes/<node>/network --type OVSBridge|OVSPort …`  
  *(Reason: Proxmox network inventory is managed through the node API; OVS objects exist here too.)*

### Use **`ovs‑vsctl`** when:
- **Tuning OVS interfaces** (e.g., jumbo):  
  `ovs-vsctl set Interface <uplink> mtu_request=9000`
- **Adding OVS glue ports** (Linux→OVS):  
  `ovs-vsctl add-port vmbrX veth-<vni>-ovs`
- **Creating OVS mirrors** for visibility and capture.  
  *(Reason: OVS‑specific runtime config lives in OVSDB; this is the correct tool.)*

### Use **Linux (`ip`/`brctl`)** when:
- **Building veth pairs** and **clamping MTU** for overlay path:  
  - `ip link add veth-<vni> type veth peer name veth-<vni>-ovs`  
  - `brctl addif vnet<vnid> veth-<vni>` → `ovs‑vsctl add-port vmbrX veth-<vni>-ovs`  
  - `ip link set veth-<vni>{,-ovs} mtu 1420`  
  *(Reason: The Linux half terminates the VNet bridge; OVS needs a port; MTU must match overlay constraints.)*

---

## 3) Limitations that enforce these method choices (the “why not”)
- **FRR EVPN limitation:** FRR learns interfaces via **Linux/Netlink**, not OVS tunnels. EVPN routes, MAC learning, and IRB attach to **Linux VXLAN + Linux bridges**.  
  → **Therefore:** VTEPs must be **Linux** (SDN). Do **not** expect FRR to consume an OVS `type=vxlan` for EVPN.

- **OVS VXLAN limitation:** OVS implements on‑wire VXLAN but lacks **multicast learning** and a **native EVPN control‑plane**.  
  → **Therefore:** Use `ovs‑vsctl` VXLAN **only** for point‑to‑point/mirroring **outside** the EVPN fabric. The fabric’s VNIs must be SDN‑rendered Linux VXLAN.

- **Proxmox API boundary:** Node `/network` supports `bridge/bond/eth/vlan/OVSBridge/OVSPort…` (no `vxlan`). VXLAN is **SDN‑only** (`/cluster/sdn`) and materializes on **Apply**.  
  → **Therefore:** Create overlays with `pvesh` **SDN** endpoints; never attempt node `type=vxlan`.

- **MTU realities:** VXLAN adds overhead; WireGuard/NetBird often caps effective MTU ≈ **1420**.  
  → **Therefore:** Clamp **Linux VXLAN + glue veth** to ~1420 on overlay paths; keep OVS uplinks at **9000** for local jumbo.

---

## 4) Build Phases (tags you’ll wire in `provision.yml`)
1. **Phase‑1 (Surfaces)**  
   - `deploy_linux_bridges`: create **`vmbr2`** + attach **`xg1`** (MTU 1420) via `pvesh`.  
   - `deploy_ovs_bridges`: ensure **`vmbr1`/`vmbr99`** + uplinks via `pvesh`; tune MTU via `ovs‑vsctl`.  
   - `deploy_sdn_vxlan`: SDN **Zone/VNets** via `pvesh` → **Apply** (renders **Linux VXLAN + VNet bridges**).  
   - `establish_glue`: create **veth** and add OVS glue ports (Linux→OVS).

2. **Phase‑2/3 (Control‑plane)**  
   - `configure_frr`: render `/etc/frr/frr.conf` with EVPN neighbors (VyOS RR) + **SVIs/VRFs** for distributed IRB; restart FRR.  
   - `configure_vyos_rr`: push VyOS RR config (RR clients + route‑map exporting peered VNIs); commit/save.

3. **Phase‑5 (Policy/visibility)**  
   - `apply_nftables`: apply nftables rulesets; optionally create OVS mirrors.

4. **Validation**  
   - `vtysh` EVPN status, `ip -d link`/`bridge fdb`, `ovs‑vsctl show`, MTU `ping -M do -s`, `tcpdump udp port 4789`.

---

## 5) Safety & Check Mode (must implement)
- In `--check`:
  - **Skip**: `pvesh create` (node + SDN), **SDN Apply**, `ovs‑vsctl add-port`, FRR restart, VyOS commit.  
  - **Do**: `pvesh get … --output-format json` preflight checks, and print **simulated actions** via `debug`.
- With flags:
  - `write_interfaces_file=false` → don’t touch `/etc/network/interfaces*`.  
  - `ovs_create=false` → no OVS creation; discover/tune only.  
  - `force_ovsclean=false` → never delete OVS ports/bridges.

---

## 6) One‑Sentence Rule (pin this so the assistant won’t drift)
> **Use `pvesh` for node interfaces and SDN (EVPN/VXLAN), use `ovs‑vsctl` only for OVS‑specific operations (mtu, patch/mirror, optional non‑EVPN vxlan), and never attempt node `/network type=vxlan`—the EVPN fabric is SDN‑driven and renders as Linux interfaces that FRR consumes; OVS is the access layer glued via veth.**

