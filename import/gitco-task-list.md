Here is a clerical/actionable list based on the recommendations in your gpt5-prompt, the current state of your repo, the updated VXLAN templates, and the network architecture in edgesec-single-tenant-bridges.mmd:

---

# Proxmox Addons: Prioritized Implementation Plan

## Phase 0: Repository Structure & Onboarding
- [ ] Establish monorepo structure and directory layout
- [ ] Enforce standards & CI/CD (linting, testing, Docker builds, secrets management)
- [ ] Write onboarding documentation (README, onboarding guide, architecture references)

## Phase 1: Proxmox Substrate & Golden Images
- [ ] Create Cloud-Init golden VM template (Ubuntu 24.04/22.04) with QEMU agent, Docker, baseline hardening
- [ ] Write Ansible inventory and playbooks for Proxmox node prep and service VM provisioning
- [ ] Automate VM/LXC lifecycle via Proxmox API tokens or Ansible modules
- [ ] Ensure bridge and overlay assignments in playbooks match the architecture diagram

## Phase 2: Core Services — DNS & Vault
- [ ] Choose and document DNS engine (CoreDNS or BIND9)
- [ ] Write Docker Compose files and Ansible automation for DNS and Vault
- [ ] Deploy and configure Vault with AppRole, batch tokens, and short TTLs
- [ ] Use Vault as the credential store for all subsequent infrastructure

## Phase 3: NetBox, Redis, and Postgres
- [ ] Deploy NetBox as source of truth for sites, tenants, VRFs, VLANs, overlays
- [ ] Deploy Redis and Postgres for service backend support
- [ ] Add custom fields for VNI, VXLAN zone, vnet_id, fabric_name in NetBox
- [ ] Set up NetBox webhooks to call edgesec-rest on create/update events

## Phase 4: edgesec-REST Service & Integrations
- [ ] Scaffold edgesec-rest (TypeScript, Fastify/NestJS, Redis, Vault, NetBox client)
- [ ] Implement hostname and VNI allocation logic (templated, deterministic)
- [ ] Integrate with Vault for secrets, Redis for caching/idempotency
- [ ] Integrate with Datto RMM and NetBox for onboarding, hostname, VNI, and VXLAN association per tenant
- [ ] Expose REST API (OpenAPI), background jobs (BullMQ), webhook consumer

## Phase 5: edgesec-RADIUS Service
- [ ] Containerize FreeRADIUS with granular config mounts
- [ ] Source secrets at runtime from Vault via edgesec-vault
- [ ] Optionally, integrate accounting to Postgres and policy management via edgesec-rest

## Phase 6: Proxmox SDN & Service Wiring
- [ ] Define SDN zone (VXLAN), VNets, and subnets in Proxmox
- [ ] Program bridges for service VNets (dns, vault, mgmt, tenant overlays)
- [ ] Automate VNet creation/updates from edgesec-rest via Ansible or Proxmox API

---

> Priority: Complete repo structure and onboarding docs first, then DNS and Vault, followed by NetBox and backend services, then edgesec-REST for onboarding automation, and finally RADIUS and SDN wiring.