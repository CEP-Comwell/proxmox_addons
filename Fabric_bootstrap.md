# Proxmox SDN Fabric: Automated Multi-Site Spine-Leaf with OpenFabric

![Spine-Leaf Fabric Architecture](blob/images/fabric_architecture.png)

---

## What does this show?

This documentation demonstrates how to use Ansible roles to automate the deployment of a scalable, secure, and automated **spine-leaf network fabric** across multiple Proxmox nodes and locations.  
It highlights a hyper-converged infrastructure approach, supporting zero trust and microsegmentation initiatives, and shows how each modular role contributes to building a robust, multi-site network fabric.

---

## Overview

The Fabric Bootstrap system is implemented as a set of Ansible roles, each responsible for a key aspect of the network fabric:

- **`underlay`**  
  Automates the configuration of the L3 underlay network, including routed interfaces and basic connectivity.

- **`bgp`**  
  Deploys and configures BGP routing for dynamic, scalable fabric control.

- **`vxlan`**  
  Automates VXLAN overlay setup for scalable L2 extension and tenant segmentation.

- **`ipam`**  
  Integrates with IP address management systems to automate address allocation and tracking.

- **`vm_nic`**  
  Manages VM network interface configuration for seamless integration with the fabric.

Each role is designed for composability, enabling you to build a robust, multi-site, microsegmented network fabric with minimal manual intervention.

---

## Features

- **Spine-Leaf Architecture:**  
  Automates deployment of a scalable, multi-site spine-leaf topology across Proxmox clusters.

- **Zero Trust & Microsegmentation:**  
  Supports advanced segmentation and security policies at the network fabric level.

- **Multi-Site Support:**  
  Enables consistent network provisioning across geographically distributed Proxmox nodes.

- **Automated Underlay & Overlay:**  
  Handles both routed underlay and VXLAN overlays for flexible, scalable networking.

- **Integrated IPAM:**  
  Automates IP address assignment and management.  
  _For Proxmox Web GUI configuration, see [configure_IPAM_in_Proxmox.md](configure_IPAM_in_Proxmox.md)._

- **Test Automation:**  
  Includes Molecule scenarios for role testing and validation.

---

## Directory Structure

- `roles/underlay/` — Underlay network automation
- `roles/bgp/` — BGP routing automation
- `roles/vxlan/` — VXLAN overlay automation
- `roles/ipam/` — IPAM integration
- `roles/vm_nic/` — VM NIC management
- `config.yml` — Central configuration for all roles
- `inventory` — Ansible inventory for your Proxmox environment
- `provision_network.yml` — Example playbook for fabric provisioning

---

## Usage

1. **Configure your inventory and `config.yml`** with your Proxmox nodes, fabric topology, and role variables.

2. **Run the network provisioning playbook:**
   ```bash
   ansible-playbook -i inventory provision_network.yml
   ```

3. **Test and validate roles using Molecule:**
   ```bash
   cd roles/underlay
   molecule test
   ```

4. **For IPAM GUI integration:**  
   See [configure_IPAM_in_Proxmox.md](configure_IPAM_in_Proxmox.md) for step-by-step instructions on integrating IPAM with the Proxmox web interface.

---

## Notes

- **Extensibility:**  
  Roles are designed for easy extension to support additional network features or integrations.

- **Security:**  
  The framework is built with zero trust and microsegmentation as core principles.

- **Documentation:**  
  Each role contains its own README and Molecule tests for clarity and maintainability.

---

MIT © CEP-Comwell