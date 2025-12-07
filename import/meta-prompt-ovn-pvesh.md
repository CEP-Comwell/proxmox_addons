# Meta‑Prompt: Explore and Implement Proxmox VE 9.1.1 SDN via pvesh

## 🎯 Objective
Guide an LLM code agent to explore the Proxmox VE 9.1.1 `pvesh` API and implement
SDN/OVN configuration commands. The agent should discover valid API endpoints,
test them, and scaffold reproducible workflows for fabrics, zones, VNets, and subnets.

---

## 🔑 Context
- Environment: Proxmox VE 9.1.1
- Hosts:
  - `pve1` → 172.16.10.20
  - `pve2` → 172.16.10.23
- SDN packages installed: `openvswitch-switch`, `ovn-common`, `ovn-host`, `ovn-central` (on pve1).
- No formal Proxmox cluster yet — but SDN objects are still defined under `/cluster/sdn/...`.

---

## 🛠️ Instructions for the Agent

### 1. Connect to the host
SSH into the primary node:

```bash
ssh root@172.16.10.20