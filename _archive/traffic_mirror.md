# edgesec-TAPx
*Modular traffic mirroring with SIEM-triggered full packet visibility.*

This subproject provides modular Ansible automation for mirroring both VM and Docker network traffic to a monitoring bridge (such as `brdpi`) on Proxmox hosts.  
It enables deep packet inspection (DPI), intrusion detection (IDS), and advanced traffic analytics for both virtual machines and containers.

---

## Overview

The solution is implemented as two distinct Ansible roles:

- **`vm_traffic_mirror`**  
  Dynamically discovers Proxmox VM tap interfaces and configures traffic mirroring to a monitoring bridge using persistent Linux bridges and veth pairs.

- **`docker_traffic_mirror`**  
  Dynamically discovers Docker bridge networks on the host and configures mirroring of container traffic to the same monitoring bridge.

Both roles support automated setup, mirroring, and cleanup of `tc` rules, and are designed for easy integration into your Proxmox automation workflows.

---

## Features

- **Dynamic Discovery:**  
  Automatically finds all relevant VM tap interfaces and Docker bridge interfaces on each Proxmox host.

- **Automated Mirroring:**  
  Uses Linux traffic control (`tc`) to mirror traffic from each interface to a dedicated monitoring bridge (`brdpi`).

- **Persistent Bridge/Veth Setup:**  
  Ensures the monitoring bridge and veth pairs are created and configured as needed.

- **Automated Cleanup:**  
  Removes mirroring rules and cleans up interfaces when no longer needed.

- **Modular Roles:**  
  Each function (VM or Docker mirroring) is encapsulated in its own Ansible role for clarity and reusability.

---

## Directory Structure

- `roles/vm_traffic_mirror/` — Role for VM tap interface mirroring
- `roles/docker_traffic_mirror/` — Role for Docker bridge mirroring
- `config.yml` — Central configuration for both roles
- `inventory` — Ansible inventory for your Proxmox and Docker hosts
- `mirror_vmbr0_to_brdpi.yml` — Playbook for VM traffic mirroring
- `monitor_docker_to_brdpi.yml` — Playbook for Docker traffic mirroring
- `cleanup_vm_traffic_mirror.yml` — Playbook for VM mirroring cleanup
- `cleanup_docker_traffic_mirror.yml` — Playbook for Docker mirroring cleanup

---

## Usage

1. **Configure your inventory and `config.yml`** with the appropriate hosts and variables.

2. **Run the VM traffic mirroring playbook:**
   ```bash
   ansible-playbook -i inventory mirror_vmbr0_to_brdpi.yml
   ```

3. **Run the Docker traffic mirroring playbook:**
   ```bash
   ansible-playbook -i inventory monitor_docker_to_brdpi.yml
   ```

4. **Cleanup (when needed):**
   ```bash
   ansible-playbook -i inventory cleanup_vm_traffic_mirror.yml
   ansible-playbook -i inventory cleanup_docker_traffic_mirror.yml
   ```

---

## Notes

- **Network Configuration:**  
  Any changes to `/etc/network/interfaces` or files in `/etc/network/interfaces.d/` are local to the Proxmox host and should be managed according to your site’s best practices.  
  The roles do not directly manage these files, but may deploy configuration files or require certain bridges to be defined.

- **Permissions:**  
  The Ansible user must have sufficient privileges to manage network interfaces and run `tc` commands on the target hosts.

- **Extensibility:**  
  The modular roles can be extended to support additional interface types or monitoring targets as needed.

---

MIT © CEP-Comwell


