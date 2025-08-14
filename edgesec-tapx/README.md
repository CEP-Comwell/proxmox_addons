# edgesec-TAPx

**edgesec-TAPx** is a modular Ansible automation suite for deploying, managing, and cleaning up network traffic mirroring (TAP) and DPI monitoring infrastructure in Proxmox and Docker environments. It is part of the Edgesec HCI automation platform.

## Features
- Automated setup and teardown of traffic mirroring (TAP) for VMs and Docker containers
- DPI bridge and veth peer management
- Playbooks for both Proxmox and Docker hosts
- Modular, reusable Ansible roles and tasks
- Designed for integration with edgesec-SDN and edgesec-REST

## Directory Structure
```
edgesec-tapx/
├── playbooks/
│   ├── cleanup_docker_traffic_mirror.yml
│   ├── cleanup_vm_traffic_mirror.yml
│   ├── dpi_bridge_cleanup.yml
│   ├── mirror_cleanup.yml
│   ├── mirror_vmbr0_to_brdpi.yml
│   ├── monitor_docker_to_brdpi.yml
│   └── ...
├── roles/
│   ├── docker_traffic_mirror/
│   ├── vm_traffic_mirror/
│   └── ...
└── README.md
```

## Usage
1. Review and edit `config.yml` and inventory files as needed for your environment.
2. Run the desired playbook from the `playbooks/` directory, e.g.:
   ```bash
   ansible-playbook playbooks/mirror_vmbr0_to_brdpi.yml -i ../../inventory
   ```
3. Use cleanup playbooks to remove TAP/DPI configuration when no longer needed.

## Integration
- Works alongside `edgesec-SDN` for overlay and underlay network automation.
- Can be orchestrated via `edgesec-REST` API for self-service or CI/CD workflows.

## Documentation
- See the root `README.md` for platform-wide architecture and onboarding.
- See playbook comments and role README files for technical details.

---
© 2025 CEP-Comwell. All rights reserved.
