Yes, you **can manage routing per bridge independently** in Proxmox VE, especially in your SDN setup with isolated bridges (`vmbr99`, `vmbr1`, `vmbr2`). Each bridge acts like a separate Layer 2 domain, and you can control how traffic flows between them using:

- **Linux routing tables**
- **`nftables` for firewall and forwarding rules**
- **VXLAN interfaces bound to specific bridges**
- **Dedicated VMs or containers acting as routers or gateways**

---

## ✅ **Example: Forward VXLAN Traffic from `vmbr99` to `xg1` (PCI-passed to NetBird VM)**

### 🧠 Assumptions:
- `vmbr99` is your **management bridge**.
- `xg1` is PCI-passed to an **Ubuntu VM** running NetBird.
- NetBird creates a WireGuard interface `wt0` inside the VM.
- You want to forward **VXLAN traffic (e.g., `vxlan10032`)** from `vmbr99` to `wt0` via `xg1`.

---

### 🔧 **Step-by-Step Routing Setup**

#### **1. On the Proxmox Host:**
Add a static route to forward VXLAN subnet traffic to the NetBird VM:

```bash
ip route add 10.10.32.0/24 via 172.16.99.100 dev vmbr99
```

- `10.10.32.0/24` is the VXLAN subnet.
- `172.16.99.100` is the IP of the NetBird VM on `vmbr99`.

This tells the host to forward traffic for `vxlan10032` to the VM.

---

#### **2. Inside the NetBird VM:**

Enable IP forwarding:

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

Add a route to forward traffic into the WireGuard tunnel:

```bash
ip route add 10.10.32.0/24 dev wt0
```

This sends VXLAN traffic into the encrypted tunnel.

---

#### **3. On the Remote Peer (e.g., another NetBird VM or host):**

Ensure the peer routes incoming traffic to its local VXLAN bridge:

```bash
ip route add 10.10.32.0/24 dev vmbr99
```

Or let `fabricd` handle it via BGP EVPN.

---

#### **4. Optional: Use `nftables` to Control Forwarding**

Example rule to allow forwarding from `vmbr99` to `wt0`:

```bash
nft add rule inet filter forward iif "vmbr99" oif "wt0" accept
```

You can also restrict by VXLAN source IP or port.

---

Would you like a full Ansible role or script to automate this routing setup across your Proxmox hosts and NetBird VMs?


Thanks for the clarification, Christopher — now that we’re focusing on **routing BGP EVPN traffic from `fabricd` (FRR) on the Proxmox host through the NetBird VM’s `wt0` interface**, here’s a clean and reliable design strategy:

---

## 🧠 **Design Objective Recap**

- FRR (`fabricd`) is running on the **Proxmox host**.
- NetBird VM has **PCI-passed `xg1` NIC** and runs a **WireGuard tunnel (`wt0`)**.
- You want **BGP EVPN traffic** (control + VXLAN data plane) to **exit via `wt0`** for secure transport.

---

## ✅ **Recommended Routing Strategy**

### 🔧 Step 1: Assign a Static IP to the NetBird VM on `vmbr99`

Let’s say the NetBird VM has:

```text
IP: 172.16.99.100
Interface: ens18 (connected to vmbr99)
Tunnel: wt0 (WireGuard)
Tunnel IP: 10.100.0.1
```

---

### 🔧 Step 2: Add a Route on the Proxmox Host

Tell FRR to forward BGP EVPN traffic to the NetBird VM:

```bash
ip route add 10.100.0.0/24 via 172.16.99.100 dev vmbr99
```

This forwards traffic destined for remote EVPN peers (via WireGuard) to the VM.

---

### 🔧 Step 3: Inside the NetBird VM

Enable forwarding:

```bash
echo 1 > /proc/sys/net/ipv4/ip_forward
```

Add a route to forward traffic into the tunnel:

```bash
ip route add 10.100.0.0/24 dev wt0
```

Or use NetBird’s routing config to advertise the tunnel subnet.

---

### 🔧 Step 4: FRR Configuration on Proxmox Host

In `/etc/frr/bgpd.conf` or via `vtysh`, advertise EVPN routes and set next-hop to the tunnel:

```bash
router bgp 65001
  neighbor 10.100.0.2 remote-as 65001
  address-family l2vpn evpn
    advertise-all-vni
    neighbor 10.100.0.2 activate
```

- `10.100.0.2` is the remote WireGuard peer.
- This ensures EVPN traffic flows securely through `wt0`.

---

### 🔧 Step 5: Use `frr-reload.py` to Apply Changes Safely

Avoid restarting FRR:

```bash
frr-reload.py --reload
```

This hot-loads the config without flapping BGP sessions.

---

Would you like a full Ansible role to automate this routing setup, including FRR config generation, route injection, and NetBird VM provisioning?