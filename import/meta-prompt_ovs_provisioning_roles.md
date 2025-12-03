````markdown
# Meta‑Prompt: Implement Flow‑Programmed VXLAN for Proxmox/OVS (Ansible + Hook)

> **Purpose**: Build an idempotent, production‑ready implementation that provisions OVS bridges and flow‑programmed VXLAN ports with Ansible, and installs a Proxmox VM lifecycle hook that adds cookie‑tagged OpenFlow rules per VNI (from `/etc/pve/vni-map.conf`).  
> **Style**: POSIX `/bin/sh` for the hook, clean and idempotent Ansible tasks, explicit validations, and concise logging.  
> **Scope**: Honor the “as‑built” architecture, policies, and operational preferences provided below.

---

## 0) Inputs & “as‑built” decisions

### Inventory & play invocation
```bash
ansible-playbook -i inventory edgesec-sdn/playbooks/provision_ovs_only.yml \
  -l pve1.comwell.edgesec.ca \
  -e "ovs_create=true write_interfaces_file=true perform_reload=true" \
  -u root
````

### Bridges & Roles

*   **Bridges**
    *   `vmbr1` (OVS, tenant/services)
    *   `vmbr99` (OVS, management)
    *   `vmbr2` (Linux bridge, gateway/edge)
*   **Roles**
    *   `ovs_bridge_provision` → bridges/veth stitching + managed block in `/etc/network/interfaces`
    *   `ovs_vxlan_provision` → VXLAN ports (`remote_ip=flow`, `key=flow`, `local_ip`, MTU), validations

### VM/NIC → VNI map (sole source of truth)

    /etc/pve/vni-map.conf
    200.net0 = 10110
    201.net0 = 10110
    202.net0 = 10102

### Per‑bridge source IPs (`options:local_ip`)

*   `vmbr1` → `10.255.0.1/28` ⇒ **`local_ip=10.255.0.1`**
*   `vmbr2` → `10.255.0.2/28` ⇒ **`local_ip=10.255.0.2`**
*   `vmbr99` → `10.255.0.99/28` ⇒ **`local_ip=10.255.0.99`**

### Fallback tun‑dst map (used by hook egress flow when EVPN isn’t ready)

*   **Required**
    *   `TUN_DST_vmbr1=10.255.0.2`   (tenant fabric peer)
    *   `TUN_DST_vmbr2=172.16.0.2`   (VyOS/NetBird edge peer)
    *   `TUN_DST_vmbr99=<peer-ip-for-core-services>` (since vmbr99 participates in inter‑node VXLAN for core services)
*   **Optional**
    *   Omit `TUN_DST_vmbr99` if you *only* run local VNIs on vmbr99 (not the case here).

### MTU policy

*   **Local OVS bridges + VXLAN ports** (`vmbr1`, `vmbr99`):
    *   **MTU 9000** on bridge
    *   **VXLAN `mtu_request=9000`**
*   **NetBird/WireGuard gateway path + `vmbr2` (Linux bridge attached to VyOS)**:
    *   **MTU 1420** on `vmbr2`
    *   **VXLAN `mtu_request=1420`** on ports bound to `vmbr2`

### Hook behavior & guardrails

*   **Enable `HOOK_VERIFY=1` by default** (skip flow adds if vxlan ofport missing).
*   **Allow `ALLOW_CREATE_VX=1` only in controlled automation contexts** (Ansible or EVPN agent).
*   **Log** each auto‑create event (audit trail).
*   **Port names ≤ 8 chars** (Proxmox 9.1 GUI limiter).

### Interfaces file strategy

*   **Keep the existing hybrid process**:
    *   Controller fetch‑edit‑push (merge script)
    *   Remote atomic replace
*   Avoid removing unrelated paragraphs; scope edits to the managed OVS block.

### Day‑2 reload policy

*   Default: **no reloads, restarts, or flushes**.
*   **Only reload** when `perform_reload=true`; do it atomically and log the operation.
*   Prefer idempotent updates; avoid disruption unless explicitly requested.

***

## 1) Deliverables

### A) Ansible Role: `ovs_bridge_provision`

**Goal**: Ensure OVS installed/active; create bridges; apply MTU policy; add physical uplinks and veth glue; update the OVS block in `/etc/network/interfaces` using the existing hybrid process.

**Tasks**:

1.  Ensure `openvswitch-switch` is installed and active.
2.  Create bridges:
    *   `vmbr1` (OVS) → set L2 **MTU 9000**
    *   `vmbr99` (OVS) → set L2 **MTU 9000**
    *   `vmbr2` (Linux bridge) → set L2 **MTU 1420**
3.  Add physical uplinks to OVS bridges (e.g., `eth1` → `vmbr1`, `eth2` → `vmbr99`).
4.  Create veth pairs (`veth-vm-ext`, `veth-mgmt-ext`) and enslave appropriately (`vmbr1↔vmbr2`, `vmbr99↔vmbr2`), bring links **UP**.
5.  Render the OVS bridges block (`ovs_bridges_full.j2`) and update `/etc/network/interfaces`:
    *   Use your existing **controller merge + remote atomic replace** flow (keep hybrid approach).
    *   Do **not** remove unrelated content; only touch the managed OVS block.
6.  Optional pre‑replace validation: `ifquery --read /etc/network/interfaces --list` (if available).

### B) Ansible Role: `ovs_vxlan_provision`

**Goal**: Create/normalize VXLAN ports with `remote_ip=flow` + `key=flow`, `local_ip` pinned, MTU policy, and assert **ofport > 0** (fast‑fail). Tag with `external_ids:vni` if helpful.

**For each VXLAN port** (from `host_vars` + role vars):

*   **Create or normalize** using:
    ```bash
    ovs-vsctl --may-exist add-port <bridge> <vxname> -- \
      set interface <vxname> type=vxlan \
        options:remote_ip=flow options:key=flow options:dst_port=4789 \
        options:local_ip=<per-bridge-ip> options:nolearning=true options:csum=true \
        mtu_request=<9000|1420 per policy>
    ```
*   **MTU**:
    *   If `<bridge>` ∈ {`vmbr1`, `vmbr99`} → `mtu_request=9000`
    *   If `<bridge>` = `vmbr2` → `mtu_request=1420`
*   **Validation**:
    *   `ovs-vsctl get interface <vxname> ofport` → must be **> 0**; **fail** with a clear message if `-1`.
*   **Tag (optional)**:
    *   `external_ids:vni=<VNI>` if desired (note: since `key=flow`, VNI comes from flow’s `tun_id`).

**Idempotency**:

*   Normalization tasks use `changed_when: false`.
*   Creation steps are guarded by existence checks.

### C) Hook script: `/usr/local/sbin/ovs-vni-hook.sh` (POSIX `/bin/sh`)

**Env**:

*   `OFVER=OpenFlow13`
*   `HOOK_DRYRUN=0|1` (default 0)
*   `HOOK_VERIFY=1` (default ON)
*   `VX_PREFIX=vx` (can be `vxlan`; discovery also checks `type=vxlan key=flow`)
*   `ALLOW_CREATE_VX=0` (only set to 1 in controlled contexts)
*   `TUN_DST_vmbr1=10.255.0.2`, `TUN_DST_vmbr2=172.16.0.2`, `TUN_DST_vmbr99=<peer-ip-for-core-services>`

**Behavior**:

1.  **VM NIC discovery**: `qm config <vmid>` → resolve `fwpr<vmid>pX` → `tap<vmid>iX` → MAC → OVS interface.
2.  **Bridge membership wait**: wait until `iface-to-br` returns a bridge; also check Linux master.
3.  **VXLAN discovery**:
    *   By name `<VX_PREFIX><VNI>`
    *   Or `type=vxlan` + `options:key=flow` (flow‑programmed port) bound to the same bridge.
4.  **Ofport resolution**: robust `ovs-ofctl show` parsing (no `awk` keyword collision).
5.  **Map VNI**: read `/etc/pve/vni-map.conf` (`VMID.netX=VNI`) **only**.
6.  **Egress flow** (cookie‑tagged):
        table=0, in_port=<tap_ofport>,
        actions=set_field:<VNI>->tun_id,
                set_field:${TUN_DST_<bridge>}->tun_dst,
                output:<vx_ofport>
7.  **Ingress flow** (cookie‑tagged):
        table=0, in_port=<vx_ofport>, tun_id=<VNI>, actions=NORMAL
8.  **Cookie lifecycle**: cookie = `<vmid><nic-index>`; on `post-stop`, `del-flows "cookie=<cookie>/-1"`.
9.  **Verify mode**: if VXLAN ofport missing and `HOOK_VERIFY=1` → **skip** flows with WARN.
10. **Observability**: `ovs-vsctl set Interface <tap/fwpr> external_ids:vni=<VNI>`.

***

## 2) Variable schema & examples

### `host_vars/<node>/ovs_vxlan_ports.yml` (example)

```yaml
ovs_vxlan_ports:
  # vmbr1 (OVS, jumbo)
  - { bridge: "vmbr1", name: "vx10110", vni: 10110, local_ip: "10.255.0.1", mtu: 9000 }
  # vmbr2 (Linux, clamp)
  - { bridge: "vmbr2", name: "vx9003",  vni: 9003,  local_ip: "10.255.0.2", mtu: 1420 }
  # vmbr99 (OVS, jumbo) — core_services, inter-node VXLAN
  - { bridge: "vmbr99", name: "vx10032", vni: 10032, local_ip: "10.255.0.99", mtu: 9000 }

# Port name policy: keep names ≤ 8 chars (Proxmox 9.1 GUI limiter)
```

### Tun‑dst map injection (environment)

```bash
export TUN_DST_vmbr1=10.255.0.2
export TUN_DST_vmbr2=172.16.0.2
export TUN_DST_vmbr99=<peer-ip-for-core-services>
```

***

## 3) Validation checklist (per bridge)

1.  **Datapath presence**:
    ```bash
    ovs-ofctl -O OpenFlow13 show <bridge> | egrep '\(vx|vxlan'   # vxlan port appears with a numeric ofport
    ```
2.  **VXLAN interface is attached**:
    ```bash
    ovs-vsctl get interface <vxname> ofport                      # > 0
    ovs-vsctl list interface <vxname> | egrep 'type|options|error'
    ```
3.  **Hook flows present (after VM post-start)**:
    ```bash
    ovs-ofctl -O OpenFlow13 dump-flows <bridge> | egrep "cookie=<vmid><idx>|tun_id=<VNI>|in_port=<tap_ofport>"
    ```
4.  **Cleanup (after post-stop)**:
    ```bash
    ovs-ofctl -O OpenFlow13 dump-flows <bridge> | egrep "cookie=<vmid><idx>" || echo "flows cleaned"
    ```
5.  **MTU sanity**:
    *   `vmbr1`/`vmbr99` VXLAN ports: `mtu_request=9000`
    *   `vmbr2` VXLAN ports: `mtu_request=1420`
    *   `ip link show <bridge>` reflects expected MTU.

***

## 4) Acceptance criteria

*   Ansible runs complete cleanly with the provided `-e` flags.
*   Every VXLAN port returns **`ofport > 0`** and is visible in `ovs-ofctl show`.
*   The hook adds exactly **two cookie‑tagged flows** per VM NIC on `post-start`; **no duplicates** across restarts; flows are removed by cookie on `post-stop`.
*   MTU policy enforced: **9000** on OVS VXLAN ports; **1420** on `vmbr2`/WG path.
*   `/etc/network/interfaces` updated via the existing hybrid process **without removing unrelated content**.

***

## 5) Implementation notes

*   When setting `remote_ip=flow`, **do not quote** `flow` in `ovs-vsctl` options.
*   Normalize OVS interface options even when the port exists (`changed_when: false`).
*   Keep logs concise and actionable; log auto‑create events only when `ALLOW_CREATE_VX=1`.
*   Honor the **≤ 8 char** port name policy (Proxmox GUI limiter).

***

## 6) Non‑goals (out of scope for this prompt)

*   End‑to‑end EVPN next‑hop learning or dynamic group actions for ECMP.
*   Full reload orchestration beyond the **Day‑2 policy** (only when `perform_reload=true`).
*   Replacing the existing hybrid `/etc/network/interfaces` process with a different strategy.

```

**End of meta‑prompt.**
```
# verify vx ofports and flows
ovs-vsctl --columns=name,ofport,type list Interface | egrep "vx10110|vx9006|vx9000|vx10031|vx10032|vx10100|vx10101|vx10102" || true
ovs-ofctl -O OpenFlow13 dump-flows vmbr1 | sed -n '1,200p'
ovs-ofctl -O OpenFlow13 dump-flows vmbr99 | sed -n '1,200p'

# If vx10110.ofport <= 0, rebind it (vmbr1 local_ip is 10.255.0.1)
ovs-vsctl --if-exists del-port vx10110
ovs-vsctl --may-exist add-port vmbr1 vx10110 \
  -- set interface vx10110 type=vxlan \
  options:key=10110 options:remote_ip=flow options:local_ip=10.255.0.1
# verify
ovs-vsctl get Interface vx10110 ofport

# If vmbr99 has a stale flow referencing in_port=7 (and port 7 is not present there), delete it:
ovs-ofctl -O OpenFlow13 del-flows vmbr99 "in_port=7"

# Force the hook to install flows for VM 200 (will create VX if allowed)
HOOK_DRYRUN=0 HOOK_VERIFY=1 ALLOW_CREATE_VX=1 /usr/local/bin/ovs-vni-hook.sh 200 post-start

# Re-check flows and counters on vmbr1
ovs-ofctl -O OpenFlow13 dump-flows vmbr1 | sed -n '1,200p'