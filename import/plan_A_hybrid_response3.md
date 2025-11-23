Thanks for sharing the assistant’s latest plan. Here’s my **clear response and alignment** so we keep everything perfectly on‑track with **Plan A (Hybrid)**.

***

## ✅ Acknowledge the good parts

*   The plan **respects gating booleans** (`write_interfaces_file`, `ovs_create`, `force_ovsclean`) and **check‑mode** first—good.
*   It proposes **idempotent, repeatable tasks** with logging and rollback—good.
*   It outlines a **PR + artifacts** flow and a **VyOS prep** doc—good.

***

## 🔧 Critical corrections (to enforce Plan A)

1.  **OVS VXLAN is *not* the EVPN fabric path**
    *   Implementing `roles/ovs_vxlan` is **optional** and **only for non‑EVPN static/mirroring tunnels**.
    *   The **EVPN fabric VNIs** must be created via **SDN (cluster endpoints) with `pvesh`**, and materialize as **Linux VXLAN + Linux VNet bridges** on Apply. FRR EVPN consumes **Linux** constructs via Netlink.
    *   Action: Keep `roles/ovs_vxlan` **gated** (e.g., `enable_ovs_static_vxlan: true`) and **exclude** it from fabric provisioning.

2.  **Do not try “pvesh vxlan” on node interfaces**
    *   Node `/network` **does not** support `type=vxlan`. VXLAN is **SDN‑only**.
    *   Action: Remove “pvesh vxlan CLI detection + fallback” logic aimed at node interfaces. If VXLAN is needed, use **SDN Zone/VNets + Apply**. Only in exceptional scenarios (not our case) would a manual Linux VXLAN stanza be written; in Proxmox VE 9, **SDN is present and should be used.**

3.  **Bridge choice for any OVS VXLAN smoke**
    *   The suggested defaults specify `bridge: vmbr2` for “OVS VXLAN” creation. `vmbr2` is a **Linux bridge** in Plan A; OVS VXLAN ports belong (optionally) on **`vmbr1`/`vmbr99`**—and again **not** for fabric VNIs.
    *   If you still want a **one‑off static VXLAN** smoke, target **`vmbr1` or `vmbr99`**, and clearly mark it **non‑EVPN/mirroring**.

4.  **MTU discipline**
    *   For overlay paths crossing WireGuard/NetBird, MTU should be **\~1420** on **Linux VXLAN** and **glue veth**. OVS uplinks can remain **9000** for local jumbo.
    *   Action: Clamp MTU where overlay traverses WG; don’t use 9000 for those VXLAN/glue interfaces.

***

## 🎯 Revised strategy for this phase (compact & actionable)

### Success criteria

*   **Node surfaces**: `vmbr2` (Linux) + `xg1` at **1420 MTU** via `pvesh`; `vmbr1`/`vmbr99` (OVS) + uplinks via `pvesh`; **mtu\_request=9000** via `ovs‑vsctl`.
*   **SDN overlays**: EVPN **Zone/VNets** via `pvesh`; **Apply** renders **Linux VXLAN/VNet bridges**.
*   **Glue**: veth pairs connect Linux VNet bridges → `vmbr1`/`vmbr99`; **1420 MTU** on overlay paths.
*   **Safety**: flags enforced; **check‑mode** shows only planned changes; **PR** has artifacts and acceptance tests.

### Work items (tight scope)

1.  **Node bridges (`pvesh`)**: idempotent creation/attachment; OVS MTU via `ovs‑vsctl`.
2.  **SDN EVPN/VXLAN (`pvesh` cluster)**: Zone + VNets with MTU; **Apply** (skip in `--check`).
3.  **Glue (Linux→OVS)**: create `veth-<vni>` / `veth-<vni>-ovs`, attach to VNet + OVS; clamp MTU.
4.  **Optional static OVS VXLAN role**: kept **gated** and **not** used for fabric VNIs.
5.  **Check‑mode and smoke**:
    *   **Check‑mode**: `deploy_linux_bridges`, `deploy_ovs_bridges`, `deploy_sdn_vxlan` (preflight only), `establish_glue` (simulate).
    *   **Smoke (single node)**: create one **glue** veth for a VNI; verify `ovs‑vsctl show`, `ip -d link`, `bridge fdb`.
    *   Optional: one **static OVS VXLAN** for mirroring (on `vmbr1`/`vmbr99`), then remove.
6.  **PR & VyOS prep**: assemble artifacts; draft RR/policy doc.

### Safety rules

*   `write_interfaces_file=false` → no writes to `/etc/network/interfaces*`.
*   `ovs_create=false` → no OVS creation; discover/tune only.
*   `force_ovsclean=false` → no deletions.
*   `--check` → **no changes** (preflight only).

***

## ▶️ Recommendation on the assistant’s next step

Please reply **(B) Hold**—we’ll supply parameters consistent with Plan A:

*   **Fabric VNIs (EVPN)**: use **SDN**
    *   Zone: `edgesec-evpn`
    *   VNets/MTU: per your diagram (e.g., `vnet10031`, `vnet10032`, `vnet10110`, `vnet9006`) with **1420** where they traverse WG; **9000** for strictly local jumbo paths.
*   **Glue targets**:
    *   `vnet10031` → **`vmbr99`**
    *   `vnet10032` → **`vmbr99`**
    *   `vnet10110` → **`vmbr1`**
    *   `vnet9006`  → **`vmbr1`**
*   **Optional static OVS VXLAN test (non‑EVPN/mirror)**:
    *   If desired, 1 temporary port on **`vmbr1`** (VNI **10110**, `dst_port=4789`, `remote_ip=` your collector) and remove after verification.

Once we pass **check‑mode** with those inputs, we’ll schedule the **smoke glue test** and proceed to the **PR**. Then we’ll begin the **VyOS RR/policy** phase.

If you prefer to proceed immediately, say **“Proceed with Plan A parameters”**, and I’ll send the exact variable block and tag sequence for the assistant to run in `--check` before any live change.
