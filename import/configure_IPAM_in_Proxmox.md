# Configure IPAM in Proxmox VE 9 (GUI)

This guide explains how to enable and configure the Proxmox IPAM plugin for dynamic IP assignment and pool management.

---

## 🧭 Enable IPAM in the Cluster

Log into the Proxmox VE 9 web interface.

**Navigate to Datacenter → Options.**

- Scroll to IPAM Enabled.
- Set it to Yes and click Apply.

This activates IPAM across all nodes in the cluster.

---

## 🧱 Define Flat Networks (Legacy VLANs)

These represent your physical underlay networks (VLANs 10, 20, 30).

Go to **Datacenter → IPAM → Networks**.

**Click Create and choose:**
- Type: Flat
- Name: vlan10-flat
- CIDR: 172.16.10.0/24
- Gateway: 172.16.10.1

**Repeat for:**

- vlan20-flat → 172.16.20.0/24 → gateway 172.16.20.1
- vlan30-flat → 172.16.30.0/24 → gateway 172.16.30.10

These will be used for legacy VM provisioning or static routing.

---

## 🌐 Create VXLAN Pools

These are tied to your overlays and used for dynamic VM provisioning.

**Internal Overlay (VXLAN 10010)**

Go to **Datacenter → IPAM → Pools.**

**Click Create:**

- Name: vxlan-internal
- CIDR: 10.10.10.0/24
- Gateway: 10.10.10.1
- VNI: 10010
- Bridge: vmbrinternal
- Type: VXLAN

**Proxy Overlay (VXLAN 10020)**

**Repeat with:**

- Name: vxlan-proxy
- CIDR: 10.10.20.0/24
- Gateway: 10.10.20.1
- VNI: 10020
- Bridge: vmbrproxy

**Ceph/ZFS Replication (VXLAN 10030 & 10031)**

**Repeat for:**

- vxlan-ceph-pub → 10.10.30.0/24 → gateway 10.10.30.1 → VNI 10030 → bridge vmbrceph_pub
- vxlan-ceph-cluster → 10.10.31.0/24 → gateway 10.10.31.1 → VNI 10031 → bridge vmbrceph_cluster

---

## 📌 Reserve Gateway IPs

To prevent IPAM from assigning .1 to VMs:  
Go to **Datacenter → IPAM → Pools.**

- Select each pool (e.g. vxlan-internal).
- **Click Edit → Reserved IPs.**
- Add:
  ```
  10.10.10.1 (internal gateway)
  10.10.20.1 (proxy gateway)
  10.10.30.1 and 10.10.31.1 (Ceph/ZFS gateways)
  ```
This ensures your Leaf2 host or router retains the gateway IP.

---

## 🖥️ Use IPAM When Creating VMs

Go to **Create VM**.

In the Network tab: **Choose Bridge: e.g. vmbrinternal**

- Enable Use IPAM
- Select the appropriate pool: e.g. vxlan-internal
- IPAM will auto-assign the next available IP from the pool.

---

## 🧠 Tips

- You can view IP usage and reservations under **Datacenter → IPAM → Pools → Usage.**
- IPAM works with Cloud-Init and DHCP-less provisioning.
- You can also use the API (`pvesh get /ipam/pools`) for automation.

---

MIT © CEP-Comwell