# edgesec-SDN

This directory contains playbooks, Docker Compose files, and documentation for the edgesec-SDN (Software Defined Networking) automation stack.

## Playbooks

Located in `playbooks/`:
- `provision_network.yml`: Main SDN fabric provisioning playbook.
- `site1_bootstrap.yml`, `site2_bootstrap.yml`, `site3_bootstrap.yml`: Per-site bootstrap playbooks for multi-site SDN deployment.
- `preflight_connectivity.yml`: Checks connectivity between all Proxmox nodes before BGP peering.
- `establish_fabric.yml`: Interactive BGP peering and fabric activation.

## Docker Compose

Place SDN-related Docker Compose files in the `docker/` subdirectory. Each file should be named and documented for its specific purpose (e.g., `docker-compose.sdn.yml`).

## Usage

1. Edit inventory and config files as needed.
2. Run playbooks from the `playbooks/` directory.
3. Use Docker Compose files from the `docker/` directory for SDN-related services.

See the main repo README and `Fabric_bootstrap.md` for more details.
