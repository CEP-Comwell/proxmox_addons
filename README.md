# PROXMOX_ADDONS

This repository provides advanced Ansible automation and monitoring add-ons for Proxmox-based hyper-converged infrastructure.  
It is designed to enable secure, scalable, and observable environments, supporting zero trust and microsegmentation initiatives.

---

## 📦 Subprojects

### [Proxmox VM & Docker Traffic Mirroring](traffic_mirror.md)
Automate the mirroring of both VM and Docker network traffic to a monitoring bridge for deep packet inspection (DPI), intrusion detection (IDS), or security analytics.

**Features:**
- Dynamic discovery of Proxmox VM tap interfaces and Docker bridge interfaces.
- Automated setup of persistent Linux bridges and veth pairs for traffic redirection.
- Application and cleanup of `tc` mirroring rules for both VMs and containers.
- Modular Ansible roles for easy integration and extension.

**Use case:**  
Gain full visibility into east-west and north-south traffic in your Proxmox clusters, supporting advanced security and compliance requirements.

---

### [Fabric Bootstrap](Fabric_bootstrap.md)
A comprehensive Ansible framework for deploying a **spine-leaf network fabric** across multiple Proxmox nodes and locations.

**Features:**
- Implements a scalable, multi-site, spine-leaf architecture for hyper-converged infrastructure.
- Automates underlay (L3), BGP, VXLAN, and IPAM configuration.
- Supports zero trust and microsegmentation at the network fabric level.
- Includes Molecule-based testing for all roles.
- Designed for rapid, repeatable, and secure network provisioning.

**Use case:**  
Quickly bootstrap a secure, multi-site, microsegmented network fabric for Proxmox clusters, enabling zero trust and advanced segmentation strategies.

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


