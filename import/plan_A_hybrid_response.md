
## ✅ I understand the direction

We’ll **finish robust deployments of OVS bridges and Linux bridge/subinterfaces first**, using **safe `pvesh`** and **deterministic fallbacks**, then move to **VyOS integration** (RR/policy for EVPN). The immediate phase must remain aligned with **Plan A (Hybrid)**:

*   **Fabric VXLAN/EVPN** is **SDN‑driven** and **renders as Linux VXLAN + Linux VNet bridges** on Apply.
*   **OVS** is the **access layer** for VM taps, VLAN‑aware switching, **mirroring**, and Calico/eBPF.
*   **Glue** Linux VNet bridges into OVS via **veth/patch**.
*   **Distributed IRB** on Proxmox (FRR SVIs/VRFs) to **avoid local hairpin** to VyOS.
*   **VyOS** is **Route Reflector + policy**, not the local L3 hop.

## 🔍 Quick review of the assistant’s plan

I like the structure (confirmation → strategy → TODO → artifacts → PR), but one item needs correction to stay true to Plan A:

> “**Implement idempotent OVS VXLAN role** … add-port … type=vxlan options:key=… options:remote\_ip=… options:dst\_port=…”

*   That’s fine **only** for **non‑EVPN static tunnels or mirroring** use‑cases.
*   For the **EVPN fabric**, we **must not** build VXLAN on OVS; it **belongs to SDN** and **materializes as Linux VXLAN**. FRR EVPN learns Linux constructs via Netlink; it won’t consume OVS `type=vxlan` for fabric control‑plane.

So: keep an **OVS VXLAN role optional** (for mirrors/point‑to‑point), but **do not** use it for fabric VNIs. Our main flow should be **SDN zone/vnets + Apply → Linux VXLAN**, then **veth glue → OVS**.

## 🎯 Strategy to complete this phase (OVS/Linux deployments → prep for VyOS)

### High‑level goals (success criteria)

*   **OVS bridges** (`vmbr1`, `vmbr99`) and **Linux bridge** (`vmbr2`) provisioned idempotently via `pvesh`; OVS MTU tuning via `ovs‑vsctl`.
*   **SDN EVPN/VXLAN** created via `pvesh /cluster/sdn` (Zone + VNets), then **Apply** to render Linux VXLAN/VNet bridges.
*   **veth/patch glue** connects each Linux VNet bridge to the right OVS bridge; MTU aligned (≈1420 over WG, 9000 local).
*   **No destructive changes** without gating booleans; **`--check`** runs cleanly with preflights and simulated diffs.
*   **PR** with artifacts (check‑mode outputs, smoke test logs) and acceptance tests.
*   **VyOS prep doc** ready for next phase (RR/policy, FRR snippets, MTU plan).

### Focused TODO (tracked plan)

1.  **Node interfaces via `pvesh` (idempotent)**
    *   `vmbr2` (Linux bridge) + `xg1` uplink; set **1420 MTU** at link & bridge.
    *   `vmbr1`, `vmbr99` (OVS bridges) + uplinks via `OVSBridge/OVSPort`; **no create** when `ovs_create=false`.
    *   Tune OVS interface **`mtu_request=9000`** with `ovs‑vsctl`.

2.  **SDN EVPN/VXLAN via `pvesh` (cluster endpoints)**
    *   Create **Zone** and **VNets** (per VNI) with MTU policy.
    *   **Apply** to render **Linux VXLAN + VNet bridges**.
    *   In `--check`, **skip Apply** and print planned changes.

3.  **veth/patch glue (Linux → OVS)**
    *   Create veth pairs (`veth-<vni>` / `veth-<vni>-ovs`), attach Linux end to **VNet bridge**, OVS end to **vmbr1/vmbr99**, clamp **MTU 1420** on overlay paths.
    *   Respect flags: **no add‑port** when `ovs_create=false`, no changes in `--check`.

4.  **Optional `roles/ovs_vxlan`** (non‑EVPN static tunnels/mirrors only)
    *   Keep **out of fabric path**.
    *   Gate behind explicit variable (e.g., `enable_ovs_static_vxlan`) and document limited scope.

5.  **Safety & fallbacks**
    *   `write_interfaces_file=false` → never write `/etc/network/interfaces*`.
    *   `ovs_create=false` → **discover/tune** only, no creation.
    *   `force_ovsclean=false` → no deletions.
    *   **Remove** any “pvesh vxlan” fallback logic—**node `/network type=vxlan` is unsupported**; VXLAN must be via **SDN**.

6.  **Validation**
    *   `vtysh -c 'show bgp l2vpn evpn summary'` / `show evpn mac vni <id>`.
    *   `ip -d link` & `bridge fdb show` for Linux VXLAN/VNet bridges.
    *   `ovs‑vsctl show` for OVS state, glue ports, mirrors.
    *   MTU: `ping -M do -s` and `tcpdump udp port 4789`.

7.  **Artifacts & PR**
    *   Check‑mode outputs, smoke‑run logs (single node), diffs of playbooks/roles.
    *   Updated README/plan doc summarizing **Plan A** and method boundaries.
    *   Acceptance test list and “known caveats” (e.g., SDN Apply required for VXLAN rendering).

8.  **VyOS prep (next phase)**
    *   Draft RR/policy doc (route‑targets, RD/RT policy, neighbor map).
    *   FRR snippets (EVPN AFI/SAFI, RR‑client definitions).
    *   MTU alignment across WG paths; test flows (east‑west local vs inter‑site).

## 🧪 About the “Idempotent OVS VXLAN role”

*   ✅ Keep this **optional** and **explicitly non‑EVPN** (static/mirror tunnels only).
*   ❌ Do **not** implement it as part of the EVPN fabric VNIs. Those are created via **SDN** (Linux) and glued to OVS.

## 📦 Proposed tag/run sequence (unchanged)

1.  **Phase‑1, dry‑run (safe):**  
    `deploy_linux_bridges, deploy_sdn_vxlan` with `--check` and flags set to avoid changes.
2.  **Phase‑1, actual:**  
    `deploy_linux_bridges, deploy_ovs_bridges, deploy_sdn_vxlan, establish_glue` (no check).
3.  **(Later) Control‑plane:**  
    `configure_frr, configure_vyos_rr` (after this PR).
4.  **(Optional) Policy/visibility:**  
    `apply_nftables` and any OVS mirrors.

## ✅ My recommendation on their final question

Choose **(2) Wait for explicit parameters**, so we avoid accidentally creating **OVS VXLAN ports** for fabric VNIs.  
If you want a **quick smoke**, we can create **one** static OVS VXLAN port on **vmbr1** for **test/mirroring only**, **not** fabric, and remove it afterward. But for the fabric, the next concrete step is: **SDN zone/vnets → Apply → veth glue**.

If you’re good with this adjustment, I’ll:

1.  Push the roles for **`pvesh` node + SDN** and **veth glue** (idempotent, flags aware, check‑safe).
2.  Produce the **check‑mode** outputs for `pve1.comwell.edgesec.ca`.
3.  Coordinate a small **live smoke** window and assemble the PR artifacts.
4.  Start the **VyOS RR/policy** design doc right after.
