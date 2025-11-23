Absolutely—here are **three concise, implementation‑ready meta‑prompts** you can drop into GitHub Copilot (GPT‑5‑mini) to steer work exactly as you described. They’re structured to be **actionable**, **idempotent**, and aligned with your **SDN/EVPN + OVS** architecture, with **pve1** preserved as the baseline template.

> **Pinned guardrail (include in all prompts to prevent drift):**  
> **Use `pvesh` for node interfaces and SDN (EVPN/VXLAN); use `ovs‑vsctl` only for OVS‑specific operations (mtu, patch/mirror, optional non‑EVPN vxlan); never attempt node `/network type=vxlan`—EVPN is SDN‑driven and renders Linux interfaces that FRR consumes; OVS is the access layer glued via veth.**

***

## 1) Meta‑prompt — **Addressing guidance for peered subnets across sites (with local DHCP/DNS)**

**Role:** You are an LLM code assistant helping design addressing for a hybrid spine‑leaf fabric on Proxmox 9.1. VyOS runs as a route‑reflector/gateway VM attached to `vmbr2`. Internal VMs live on **OVS bridges** (`vmbr1`, `vmbr99`) to enable **Calico‑style policy** and **OVS port mirroring**; SDN renders VXLAN/VNets on **Linux surfaces** (`vmbr2`), glued to OVS via **veth pairs**.

**Objective:** Produce a **short, definitive addressing plan** for **multi‑site EVPN**, ensuring **local DHCP/DNS per site**, **no L2 stretch across sites**, and clean **Type‑5 (IP prefix) exchange** between sites.

**Rules & recommendations:**

*   **Per‑site CIDRs per VNI** (no stretched L2). Example mapping strategy:
    *   `pve1` uses baseline CIDR (e.g., `10.31.1.0/24`),
    *   `pve2` increments the site index (e.g., `10.31.2.0/24`),
    *   `pve3` increments again (e.g., `10.31.3.0/24`).
*   **SVI placement**: VNI gateways (SVIs) live on the **SDN‑rendered Linux VXLAN/VNet bridges** and are consumed by **FRR**; VyOS is RR/gateway for **north‑south** and **inter‑VNI** flows (do **not** hairpin all east‑west by default).
*   **Local services**:
    *   **DHCP**: per‑site DHCP for **each local VNI** (or DHCP relay on SVI toward local server).
    *   **DNS**: split‑horizon or delegated zones; per‑site forwarders; optional replication for shared zones (e.g., `core_services`, `edgesec_vault`).
*   **EVPN policy**:
    *   Advertise **Type‑5 prefixes** per VNI; constrain with **route‑maps** (export/import lists) at VyOS/FRR.
    *   Harden BGP/EVPN neighbors (MD5, TTL‑security, prefix‑limits, explicit RR client lists).

**Outputs (what to generate):**

1.  A **compact YAML addressing plan** for `pve1`, `pve2`, `pve3` that lists, per VNI: `{ overlay, vni, cidr, svi, bridge }`.
2.  A **one‑page checklist** covering DHCP pools, DNS forwarders, and EVPN route‑map intents per site.

**Acceptance checks:**

*   Each site has **unique CIDRs** per VNI; no overlaps.
*   All SVIs map to **correct bridges** (`vmbr1` for tenant, `vmbr99` for mgmt, `vmbr2` for gateway/ext).
*   DHCP/DNS are **local** per site; EVPN exchange shows only **intended prefixes**.

***

## 2) Meta‑prompt — **Recommended updates for `pve1` (baseline template only, no functional changes)**

**Role:** You are an LLM assistant asked to **template‑enable `pve1`** host\_vars **without changing any working behavior**. `pve1` is fully functional and must remain untouched in effect; we only add **metadata and scaffolding** to simplify cloning to `pve2` and `pve3`.

**Do (non‑functional additions only):**

*   Add **site metadata**:
    ```yaml
    site_id: 1
    site_code: "YYZ"
    ```
*   Add **IPAM policy hints** (informational keys the generator will use for future sites):
    ```yaml
    ipam_policy:
      strategy: "per-site CIDR per VNI (no L2 stretch)"
      cidr_increment_field: "third_octet"
      svi_offset: 1
    ```
*   Normalize keys used by roles (ensure presence of):
    *   `vmbr_linux_gateway`, `vmbr_ovs_tenant`, `vmbr_ovs_mgmt`
    *   `mtu_linux_gateway: 1420`, `mtu_ovs_default: 9000`
    *   `glue_vmbr1`, `glue_vmbr99`, `glue_to_mgmt`
    *   `site_vni_plan: { vni: { overlay, cidr, svi, bridge } }`
    *   `services_local: { dhcp_vnis, dns_forwarders_v4, dns_forwarders_v6 }`
    *   `frr_neighbors`, `frr_vrfs`
*   Add a **validation note**: “pve1 is the source of truth; downstream sites must be clones with CIDR/SVI adjustments only.”

**Don’t:**

*   Don’t edit existing CIDRs, SVIs, bridges, glue names, safety flags, or neighbors.
*   Don’t add or remove VNIs.
*   Don’t perform any changes to `/etc/network/interfaces*`.

**Outputs:**

*   A **diff** showing only added metadata keys (no value changes to existing keys).
*   A **README snippet** describing how `pve1` becomes the **baseline template** for multi‑site expansion.

**Acceptance checks:**

*   Running existing playbooks with `host_vars/pve1.yml` yields **identical behavior** before/after the template additions.

***

## 3) Meta‑prompt — **Generate matching host\_vars for `pve2` and `pve3` (IPAM role behavior)**

**Role:** You are an LLM assistant acting as a **mini‑IPAM generator**. Using `pve1` host\_vars as the **baseline template**, produce **new host\_vars** for `pve2` and `pve3` by cloning structure and **systematically adjusting CIDR/SVI per VNI**. Keep bridges, glue names, FRR neighbors, and safety flags consistent unless site‑specific differences are provided.

**Inputs:**

*   `host_vars/pve1.yml` (baseline) — treat as source of truth.
*   `site_id` mapping: `pve2 → 2`, `pve3 → 3`.
*   Increment rule for new sites:
    *   For CIDRs of the form `A.B.C.0/24` at `pve1`, produce `A.B.(C+site_id-1).0/24` for new sites.
    *   For SVIs, use `.1` (or the baseline `svi_offset`) unless the baseline uses a different gateway convention.

**Steps:**

1.  **Clone structure** of `pve1` host\_vars to `pve2.yml` and `pve3.yml`.
2.  For each `site_vni_plan` entry, **compute new CIDR/SVI** by applying the increment rule.
3.  Preserve `bridge` assignments (e.g., `vmbr1` tenant, `vmbr99` mgmt, `vmbr2` gateway/ext).
4.  Preserve `glue_vmbr1/glue_vmbr99` names (or append site suffix only if collisions are possible across inventory).
5.  **Services locality**: copy `dhcp_vnis`; adjust `dns_forwarders_v4` to a site‑local IP (e.g., `10.32.2.10`, `10.32.3.10`), keep `dns_forwarders_v6` as needed.
6.  Preserve `frr_neighbors` (same RR) and `frr_vrfs` bindings.
7.  Emit files as **host\_vars/pve2.yml** and **host\_vars/pve3.yml**.

**Outputs (exact files):**

*   `host_vars/pve2.yml`
*   `host_vars/pve3.yml`

**Example (one VNI across sites):**

```yaml
# pve1
site_vni_plan:
  10032: { overlay: "core_services", cidr: "10.32.1.0/24", svi: "10.32.1.1", bridge: "vmbr99" }

# pve2 (generated)
site_vni_plan:
  10032: { overlay: "core_services", cidr: "10.32.2.0/24", svi: "10.32.2.1", bridge: "vmbr99" }

# pve3 (generated)
site_vni_plan:
  10032: { overlay: "core_services", cidr: "10.32.3.0/24", svi: "10.32.3.1", bridge: "vmbr99" }
```

**Check‑mode safety (must implement):**

*   In `--check`, **do** discovery (`pvesh get … --output-format json`, `ovs‑vsctl show`) and **print simulated changes**; **skip** any `pvesh create`, SDN Apply, `ovs‑vsctl add-port`, FRR restart, VyOS commit.

**Acceptance checks:**

*   `ansible-playbook … playbooks/validate_host_vars.yml --check` passes for `pve2` and `pve3`.
*   No overlaps between `pve1`, `pve2`, `pve3` CIDRs per VNI.
*   Bridges and glue variables are consistent; MTU discipline preserved (`1420` on veth ends, `9000` OVS defaults).

**Non‑goals (explicit):**

*   Do **not** change `pve1` functional values.
*   Do **not** add/delete VNIs.
*   Do **not** introduce node `/network type=vxlan` or render EVPN on OVS.

***

### Optional helper snippet (Copilot can generate on demand)

**Validation playbook (safe & short):**

```yaml
---
- name: Validate host_vars and simulate multi-site plan
  hosts: proxmox_hosts
  gather_facts: false
  tasks:
    - name: Assert required keys
      ansible.builtin.assert:
        that:
          - site_vni_plan is mapping
          - vmbr_linux_gateway is defined
          - vmbr_ovs_tenant is defined
          - vmbr_ovs_mgmt is defined
          - mtu_linux_gateway | int == 1420
    - name: Simulate glue actions (check-mode only)
      ansible.builtin.debug:
        msg: >
          Glue vmbr2↔vmbr1: {{ glue_vmbr1.veth_linux }}<->{{ glue_vmbr1.veth_ovs }} ;
          Glue vmbr2↔vmbr99: {{ glue_to_mgmt | ternary(glue_vmbr99.veth_linux ~ '<->' ~ glue_vmbr99.veth_ovs, 'disabled') }}
      when: ansible_check_mode
```

***

If you want, I can now **instantiate** prompts 2 and 3 directly against your current `pve1` host\_vars (unchanged in effect) and produce **ready‑to‑commit** `pve2.yml` and `pve3.yml` files.
