# EdgeSec-Vault

This project provides a HashiCorp Vault deployment for the EdgeSec HCI platform, serving as the central source of truth for all credentials and secrets. It is designed for multi-tenant environments and integrates with the Proxmox SDN Fabric and other EdgeSec platform components.

## Features
- Centralized secrets management for EdgeSec HCI
- Multi-tenant isolation using Vault namespaces
- Ready for integration with EdgeSec-RADIUS, EdgeSec-REST, and other platform services
- Easy deployment via Docker Compose

## Quick Start

1. **Clone the repository and navigate to the `edgesec-vault` directory.**

2. **Start Vault using Docker Compose:**
   ```bash
   docker-compose up -d
   ```

3. **Initialize and unseal Vault:**
   Follow the instructions in the Vault logs to initialize and unseal your Vault instance.

4. **Create tenant namespaces:**
   Use the Vault CLI or API to create isolated namespaces for each tenant:
   ```bash
   vault namespace create tenant1
   vault namespace create tenant2
   # ...repeat for each tenant
   ```

5. **Configure PKI engines, policies, and authentication backends as needed.**

## Example Docker Compose
See `docker-compose.yml` in this directory for a production-ready Vault deployment.

## References
- [Vault Namespaces Documentation](https://developer.hashicorp.com/vault/docs/enterprise/namespaces)
- [Vault Docker Documentation](https://hub.docker.com/_/vault)
- [EdgeSec Platform Overview](../README.md)
