I am provisioning a multi-tenant SDN fabric using Proxmox VE 9.0.11 with isolated Linux bridges (`vmbr99`, `vmbr1`, `vmbr2`) and multiple VXLAN overlays. I use Ansible and `pvesh` to automate SDN provisioning. My goal is to accelerate BGP EVPN routing performance between Proxmox hosts using encrypted WireGuard tunnels managed by NetBird.

Key VXLANs and bridges:
- vmbr99: management (e.g., vx10100, vx10101, vx10102, vx10031, vx10032)
- vmbr1: tenant services (e.g., vx10110, vx9000, vx9006)
- vmbr2: hybrid leaf gateway (e.g., vx9003, vx10120)

NetBird is deployed inside an Ubuntu VM with PCI passthrough of a 10GbE NIC (`xg1`). The VM acts as a WireGuard gateway (`wt0`) for EVPN traffic. I cannot install NetBird on the Proxmox host directly.

### ✅ Decisions and Best Practices:
1. **Use routing, not NAT**, between `vmbr99` and `wt0` inside the NetBird VM to avoid performance loss and preserve EVPN endpoint integrity.
2. **Enable IP forwarding** and configure static routes or BGP peering between `fabricd` on the host and FRR inside the VM.
3. **Avoid restarting FRR** — use `frr-reload.py` or `vtysh` to hot-load BGP route advertisements and avoid session flaps.
4. **Tune MTU** across bridges and WireGuard interfaces to avoid fragmentation (e.g., set MTU to 1420 or use jumbo frames if supported).
5. **Assign dedicated vCPUs** to the NetBird VM and ensure AES-NI and AVX2 are available for ChaCha20 acceleration.
6. **Monitor performance** using `iperf3` and `netbird status`.

### 🔧 Automation Goals:
- Generate `frr.conf.local` using Ansible and Jinja2 templates based on `sdn_vni_plan`.
- Use `pvesh` to define SDN zones, VNets, and controllers.
- Deploy FRR config safely using `frr-reload.py` via Ansible.
- Validate BGP EVPN convergence and VXLAN reachability across hosts.

Please generate:
- Ansible role structure (`tasks/`, `templates/`, `handlers/`)
- Jinja2 template for `frr.conf.local` using VXLAN CIDRs
- Ansible tasks to push config and reload FRR safely
- Optional: `pvesh` commands to define SDN zones and VNets