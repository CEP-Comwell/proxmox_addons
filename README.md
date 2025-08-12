# PROXMOX_ADDONS

This repository provides advanced Ansible automation and monitoring add-ons for Proxmox-based hyper-converged infrastructure.  
It is organized into modular subprojects, each with its own documentation and roles.

---

## 📦 Subprojects

### [Proxmox VM & Docker Traffic Mirroring](traffic_mirror.md)
Automate the mirroring of VM and Docker network traffic to a monitoring bridge for DPI, IDS, or security analysis.  
Includes dynamic discovery of tap and Docker bridge interfaces, persistent bridge/veth setup, and automated cleanup.

### [Proxmox SDN Fabric: Automated Multi-Site Spine-Leaf with OpenFabric](Fabric_bootstrap.md)
A comprehensive Ansible framework for deploying a **spine-leaf network fabric** across multiple Proxmox nodes and locations, powered by OpenFabric.  
Implements scalable, multi-site, zero trust, and microsegmentation strategies for hyper-converged infrastructure.

### [EdgeSec-RADIUS](edgesec-radius.md)
Modular Ansible role for multi-tenant, certificate-based authentication and integration with Vault, Authentik, Smallstep CA, FreeRADIUS, and NetBox.

### [EdgeSec-REST Backend](edgesec-rest/README.md)
Device enrollment backend following clean architecture and facade patterns. Includes CLI runner and Jest tests.

---

## 🗂 Directory Structure

- `roles/` — Ansible roles for each feature or subproject
- `traffic_mirror.md` — Documentation for VM & Docker traffic mirroring
- `Fabric_bootstrap.md` — Documentation for the Proxmox SDN Fabric system
- `config.yml` — Central configuration for playbooks
- `inventory` — Ansible inventory file for your environment

---

## 🚀 Getting Started

Each subproject has its own quick start and requirements.  
See [traffic_mirror.md](traffic_mirror.md) and [Fabric_bootstrap.md](Fabric_bootstrap.md) for details.

---

MIT © CEP-Comwell


