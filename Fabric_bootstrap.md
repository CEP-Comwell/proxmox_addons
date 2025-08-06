# 🚀 Proxmox Fabric Bootstrap

Provision a full spine-leaf overlay network on Proxmox using modular Ansible roles. This playbook automates underlay VLANs, VXLAN overlays, IPAM integration, BGP peering, NAT/firewall rules, and optional Ceph/ZFS replication bridges.

---

## 🧰 Features

- 🔌 Underlay VLAN bridges (`vmbr10`, `vmbr20`, `vmbr30`)
- 🌐 VXLAN overlays for internal, proxy, Ceph public, and cluster traffic
- 📦 IPAM pools for dynamic VM provisioning
- 🧭 BGP sessions between spine and leaf nodes
- 🔥 NAT/SNAT for egress traffic
- 🛡️ Proxmox firewall rules for ingress control
- 🧪 Molecule tagging for targeted testing
- 🧬 Optional Ceph/ZFS replication overlays

---

## 📁 Role Breakdown

| Role           | Description                                   |
| -------------- | --------------------------------------------- |
| `underlay`     | Sets up physical bridges and VLANs            |
| `bgp`          | Configures FRR BGP sessions                   |
| `vxlan`        | Creates VXLAN interfaces and bridges          |
| `ipam`         | Registers IPAM pools in Proxmox               |
| `vm_nic`       | Attaches VM NICs to correct overlays          |
| `nat`          | Applies SNAT rules for internal traffic       |
| `proxy`        | Configures firewall rules for Traefik ingress |
| `ceph_network` | Sets up Ceph/ZFS replication bridges          |

---
🧠 What This Shows
**Stage 1:** Each site builds its host independently, installing required packages (FRR, IPAM).

**Stage 2: **Underlay configuration begins—BGP peering, VXLAN setup, and IPAM pools.

Connection: The underlay links both sites via BGP/VXLAN.

![alt text](image.png)

---

## 📦 Requirements

- Proxmox VE 9.0+ (required for SDN Fabrics and fabricd)
- Ansible 2.10+
- FRR installed on all nodes
- Proxmox IPAM plugin (optional)
- Molecule + Testinfra (for testing)

---

## 🔧 Installation Steps

### 🧭 Install FRR (Free Range Routing)

FRR is required for BGP peering and dynamic routing.

```bash
echo "deb http://deb.frrouting.org/frr $(lsb_release -s -c) frr-stable" | tee /etc/apt/sources.list.d/frr.list
curl -s https://deb.frrouting.org/frr/keys.asc | apt-key add -
apt update
apt install frr frr-pythontools -y
```

Enable and start the FRR service:

```bash
systemctl enable frr
systemctl start frr
```

---

### 📦 Install Proxmox IPAM Plugin (Optional but Recommended)

IPAM allows dynamic IP assignment for VMs and overlays.

```bash
apt update
apt install pve-ipam -y
```

Enable IPAM in the cluster config:

```bash
pvesh set /cluster/config --ipam 1
```

Then configure pools via GUI or API.

### 🧭 Enable and Configure IPAM in Proxmox VE 9 (GUI)

✅ **Step 1: Enable IPAM in the Cluster**
Log into the Proxmox VE 9 web interface.

Navigate to Datacenter → Options.

Scroll to IPAM Enabled.

Set it to Yes and click Apply.

This activates IPAM across all nodes in the cluster.

🧱 **Step 2: Define Flat Networks (Legacy VLANs)**
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

🌐 **Step 3: Create VXLAN Pools**
These are tied to your overlays and used for dynamic VM provisioning.

Internal Overlay (VXLAN 10010)

**Go to Datacenter → IPAM → Pools.**

**Click Create:**

Name: vxlan-internal

- CIDR: 10.10.10.0/24

- Gateway: 10.10.10.1

- VNI: 10010

- Bridge: vmbrinternal

- Type: VXLAN

- Proxy Overlay (VXLAN 10020)

**Repeat with:**

Name: vxlan-proxy

- CIDR: 10.10.20.0/24

- Gateway: 10.10.20.1

- VNI: 10020

- Bridge: vmbrproxy

- Ceph/ZFS Replication (VXLAN 10030 & 10031)

**Repeat for:**

- vxlan-ceph-pub → 10.10.30.0/24 → gateway 10.10.30.1 → VNI 10030 → bridge vmbrceph_pub

- vxlan-ceph-cluster → 10.10.31.0/24 → gateway 10.10.31.1 → VNI 10031 → bridge vmbrceph_cluster

📌 **Step 4: Reserve Gateway IPs**
To prevent IPAM from assigning .1 to VMs:

Go to Datacenter → IPAM → Pools.

Select each pool (e.g. vxlan-internal).

Click Edit → Reserved IPs.

Add:
```bash
10.10.10.1 (internal gateway)

10.10.20.1 (proxy gateway)

10.10.30.1 and 10.10.31.1 (Ceph/ZFS gateways)
```
This ensures your Leaf2 host or router retains the gateway IP.

🖥️ **Step 5: Use IPAM When Creating VMs**
Go to Create VM.

In the Network tab:

Choose Bridge: e.g. vmbrinternal

Enable Use IPAM

Select the appropriate pool: e.g. vxlan-internal

IPAM will auto-assign the next available IP from the pool.

🧠 **Tips**
You can view IP usage and reservations under Datacenter → IPAM → Pools → Usage.

IPAM works with Cloud-Init and DHCP-less provisioning.

You can also use the API (pvesh get /ipam/pools) for automation.
---

### 🧪 Install Molecule + Testinfra (for Role Testing)

Use a Python virtual environment to isolate dependencies:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install molecule molecule-docker testinfra ansible
```

Verify installation:

```bash
molecule --version
```

You’re now ready to run:

```bash
molecule converge
```

Use tags to target specific tests:

```bash
molecule converge --tags verify_bgp,verify_vxlan
```

Refer to `molecule_tags.conf` for available tags.

## 🚀 Usage

### 1. Clone the Repository

git clone https://github.com/CEP-Comwell/proxmox_addons.git
cd proxmox_addons

### 2. Review Inventory
Edit **inventory.yml** to define your Proxmox nodes and group structure.

Example:
```bash
yaml
all:
  children:
    proxmox:
      hosts:
        pve-node1:
        pve-node2:
```
Make sure hostnames match your actual Proxmox nodes.

### 3. Customize Variables
Edit **group_vars/all.yml** or role-specific defaults to match your environment:

- **VLAN IDs and bridge names**
- **IP ranges for overlays**
- **BGP neighbors and ASNs**
- **Proxy VM IP address**
- **NAT source IPs**
- **Ceph/ZFS replication settings (optional)**

### 4. Run the Playbook
Execute the full provisioning playbook:

```bash
ansible-playbook provision_network.yml -i inventory.yml
```

This will apply all roles in sequence:

- **Underlay bridges**
- **VXLAN overlays**
- **IPAM pools**
- **BGP sessions**
- **NAT/firewall rules**
- **Optional Ceph/ZFS overlays**

### 5. Run Molecule Tests
Use Molecule to test specific components:

```bash
molecule converge --tags verify_bgp,verify_vxlan
```
Available tags include:

- **verify_underlay**
- **verify_bgp**
- **verify_vxlan**
- **verify_ipam**
- **verify_nat**
- **verify_proxy**
- **verify_ceph**

Refer to molecule_tags.conf for the full list.

### 🧠 Notes
vmbrceph_pub and vmbrceph_cluster are optional bridges for Ceph or ZFS replication.

Firewall rules default to DROP with explicit ACCEPT for HTTP, HTTPS, and ICMP.

Roles are modular—run them individually or as a full stack.

Cloud-Init integration is planned for future versions.

IPAM integration is optional but recommended for dynamic VM provisioning.

📜 License
MIT © CEP-Comwell