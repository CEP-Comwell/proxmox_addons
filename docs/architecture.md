# EdgeSec Platform Architecture

This document provides a high-level overview of the EdgeSec HCI platform, its modular subprojects, and integration points.

## Subprojects
- **Traffic Mirroring:** VM & Docker network traffic mirroring for DPI/IDS.
- **SDN Fabric:** Automated multi-site spine-leaf network with OpenFabric.
- **EdgeSec-RADIUS:** Multi-tenant certificate-based authentication and integration with Vault, Authentik, Smallstep CA, FreeRADIUS, NetBox.
- **EdgeSec-REST Backend:** Device enrollment backend using clean architecture.
- **EdgeSec-Vault:** Centralized secrets management with HashiCorp Vault, supporting tenant namespaces.

## Integration Diagram
```
[Proxmox Nodes]
   |
[SDN Fabric (OpenFabric)]
   |
[Traffic Mirroring]---[EdgeSec-RADIUS]---[EdgeSec-REST]---[EdgeSec-Vault]
   |                        |                |
   |                        |                |
[NetBox]               [Authentik]      [Smallstep CA]
   |
[FreeRADIUS]
```

## Best Practices
- Modular structure for maintainability
- Dedicated documentation for each subproject
- Secure secrets management and automation
- Real-world examples and use cases

## References
- See each subproject's README for details and quick start.
