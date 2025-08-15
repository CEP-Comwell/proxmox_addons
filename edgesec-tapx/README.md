# edgesec-TAPx
*Modular traffic and probe automation for full packet visibility and DPI in Proxmox and Docker environments.*

This subproject provides modular Ansible automation for probing and mirroring VM, Docker, VXLAN, and HCI agent network traffic to a monitoring bridge (such as `brdpi`) on Proxmox hosts. It enables deep packet inspection (DPI), intrusion detection (IDS), and advanced traffic analytics for both virtual machines and containers.

---

## Overview

The solution is implemented as modular Ansible roles and playbooks:

- **`probe-vm-net`**  
  Probes and mirrors VM network traffic (e.g., mirrors `vmbr0` to `brdpi`).
- **`probe-docker-overlay`**  
  Probes and mirrors Docker overlay network traffic.
- **`probe-vxlan-node`**  
  Probes VXLAN node-level traffic (template for overlay/underlay analysis).
- **`probe-hci-agent`**  
  Probes HCI agent-based active response (template for agent-driven probes).

Each role supports automated setup, mirroring, and cleanup, and is designed for easy integration into your Proxmox automation workflows.

---

## Features

- **Dynamic Discovery:**  
  Automatically finds all relevant VM tap interfaces, Docker bridge interfaces, and VXLAN endpoints on each Proxmox host.

- **Automated Probing & Mirroring:**  
  Uses Linux traffic control (`tc`) and bridge/veth setup to mirror or probe traffic to a dedicated monitoring bridge (`brdpi`).

- **Persistent Bridge/Veth Setup:**  
  Ensures the monitoring bridge and veth pairs are created and configured as needed.

- **Automated Cleanup:**  
  Removes mirroring rules and cleans up interfaces when no longer needed.

- **Modular Roles:**  
  Each probe function is encapsulated in its own Ansible role for clarity and reusability.

---

## Directory Structure

- `roles/probe-vm-net/` — Role for VM network probing and mirroring
- `roles/probe-docker-overlay/` — Role for Docker overlay probing
- `roles/probe-vxlan-node/` — Role for VXLAN node-level probing
- `roles/probe-hci-agent/` — Role for HCI agent-based probing
- `config.yml` — Central configuration for all probe roles
- `inventory` — Ansible inventory for your Proxmox and Docker hosts
- `playbooks/probe-vm-net.yml` — Playbook for VM network probing
- `playbooks/probe-docker-overlay.yml` — Playbook for Docker overlay probing
- `playbooks/probe-vxlan-node.yml` — Playbook for VXLAN node-level probing
- `playbooks/probe-hci-agent.yml` — Playbook for HCI agent-based probing
- Cleanup playbooks for each probe role

---

## Usage

1. **Configure your inventory and `config.yml`** with the appropriate hosts and variables.

2. **Run a probe playbook:**
   ```bash
   ansible-playbook -i inventory playbooks/probe-vm-net.yml
   ansible-playbook -i inventory playbooks/probe-docker-overlay.yml
   ansible-playbook -i inventory playbooks/probe-vxlan-node.yml
   ansible-playbook -i inventory playbooks/probe-hci-agent.yml
   ```

3. **Cleanup (when needed):**
   ```bash
   ansible-playbook -i inventory playbooks/cleanup_probe-vm-net.yml
   ansible-playbook -i inventory playbooks/cleanup_probe-docker-overlay.yml
   ansible-playbook -i inventory playbooks/cleanup_probe-vxlan-node.yml
   ansible-playbook -i inventory playbooks/cleanup_probe-hci-agent.yml
   ```

---

## Notes

- **Network Configuration:**  
  Any changes to `/etc/network/interfaces` or files in `/etc/network/interfaces.d/` are local to the Proxmox host and should be managed according to your site’s best practices. The roles do not directly manage these files, but may deploy configuration files or require certain bridges to be defined.

- **Permissions:**  
  The Ansible user must have sufficient privileges to manage network interfaces and run `tc` commands on the target hosts.

- **Extensibility:**  
  The modular probe roles can be extended to support additional interface types, monitoring targets, or active response mechanisms as needed.

---

MIT © CEP-Comwell
