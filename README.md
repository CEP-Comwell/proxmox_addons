# Proxmox VM Traffic Mirroring with Ansible

This Ansible playbook configures traffic mirroring from VMs connected to `vmbr0` to a monitoring bridge (`brdpi`) using a `veth` interface (`veth0`). It uses `tc` (traffic control) to mirror egress traffic from each VM's TAP interface.

---

## 📦 Features

- Dynamically discovers TAP interfaces (e.g., `tap400i0`)
- Excludes monitoring VMs by VMID
- Applies `tc` mirroring rules to forward traffic to `veth0`
- Designed for Proxmox 8.x

---

## 🛠 Requirements

- Ansible installed on your control node
- SSH access to Proxmox host(s)
- `tc` available on the Proxmox host
- Monitoring VM connected to the `brdpi` bridge

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/CEP-Comwell/proxmox_addons.git
cd proxmox_addons

