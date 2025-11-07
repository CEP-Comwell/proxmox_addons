## 🧠 Meta-Prompt: Unified SDN Bridge Provisioning Role for Proxmox VE 9.0.11

You are a code assistant helping to build infrastructure automation using Ansible for a Proxmox VE 9.0.11-based SDN environment. Please create a new Ansible role called `bridge_provision` that manages all bridge interfaces on the Proxmox host. This role will replace the need for separate OVS and Linux bridge roles and should integrate with the existing `group_vars` and `host_vars` structure already defined in the repository.

---

### 🔧 OVS Bridge Provisioning

- Provision the following OVS bridges using `ovs-vsctl`:
  - `vmbr99`: Management bridge (shared across all nodes)
  - `vmbr1`: Tenant bridge (VXLAN VNIs are tenant-specific and defined per-node)
- Ensure idempotency using `--may-exist`.
- Set MTU to `9000` and bring up each bridge.
- Allow templating of VXLAN VNIs and port mappings via `group_vars` and `host_vars`.

---

### 🧱 Linux Bridge Provisioning (`vmbr2`)

- Provision `vmbr2` as a Linux bridge using standard tools (`ip link`, `bridge`, etc.).
- Set MTU to `1420` and bring up the interface.
- Create sub-interfaces on `vmbr2` for:
  - `gateway1`, `gateway2`
  - Legacy VLAN-VNI mappings (e.g., VLAN 100 → VNI 10031)
  - Ingress proxy (`vxlan9003`)
  - NetBird EVPN gateway (`vxlan9006`)
- These sub-interfaces are created on the Proxmox host and attached to VyOS via `vmbr2`.

---

### 🧠 VyOS Responsibilities

VyOS is attached to `vmbr2` and will handle:
- Inter-VNI routing
- nftables firewall rules
- Routing between VXLANs and legacy VLANs
- Exposure of ingress proxy and Vault services to tenants

---

### 📦 Variable Structure

- `group_vars/all.yml` defines shared bridge parameters (e.g., MTU, bridge names).
- `host_vars/<hostname>.yml` defines tenant-specific VXLAN VNIs, VLAN mappings, and bridge port configurations.

---

### 🧪 Output Expectations

- Create `roles/bridge_provision/` with:
  - `tasks/main.yml`
  - `defaults/main.yml`
  - (optional) `handlers/main.yml`
- Include example `group_vars` and `host_vars` entries.
- Update `playbooks/provision.yml` to use the new role.
- Ensure all tasks are idempotent and reusable across all Proxmox nodes.