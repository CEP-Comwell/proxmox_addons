# PROXMOX_ADDONS

This repository provides advanced Ansible automation and monitoring add-ons for Proxmox environments.  
It is organized into modular subprojects, each with its own documentation and roles.

---

## 📦 Subprojects

### [Proxmox VM & Docker Traffic Mirroring](traffic_mirror.md)
Automate the mirroring of VM and Docker network traffic to a monitoring bridge for DPI, IDS, or security analysis.  
Includes dynamic discovery of tap and Docker bridge interfaces, persistent bridge/veth setup, and automated cleanup.

### [Fabric Bootstrap](Fabric_bootstrap.md)
A flexible Ansible-based framework for bootstrapping network fabrics, including underlay, BGP, VXLAN, and IPAM roles.  
Supports multi-role provisioning and test automation with Molecule.

---

## 🗂 Directory Structure

- `roles/` — Ansible roles for each feature or subproject
- `traffic_mirror.md` — Documentation for VM & Docker traffic mirroring
- `Fabric_bootstrap.md` — Documentation for the Fabric Bootstrap system
- `config.yml` — Central configuration for playbooks
- `inventory` — Ansible inventory file for your environment

---

## 🚀 Getting Started

Each subproject has its own quick start and requirements.  
See [traffic_mirror.md](traffic_mirror.md) and [Fabric_bootstrap.md](Fabric_bootstrap.md) for details.

---

MIT © CEP-Comwell


