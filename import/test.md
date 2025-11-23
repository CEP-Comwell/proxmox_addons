Absolutely, Christopher — let’s add the **idempotent Glue creation tasks** you need right now, aligned with your architecture and safety rules.

Below is a **drop‑in Ansible task file** (`roles/edgesec_sdn/tasks/establish_glue.yml`) that:

*   Creates **vmbr2↔vmbr1** and optionally **vmbr2↔vmbr99** veth pairs
*   Clamps **MTU = 1420** on both veth ends to match your gateway path
*   Is **idempotent** (won’t re-create if present)
*   Is **safe in `--check`** (prints simulated actions only)
*   Uses **`ovs-vsctl --may-exist add-port`** and **`mtu_request`** for OVS ports

> **Pinned rule reminder (kept visible for drift prevention):**  
> Use `pvesh` for node interfaces and SDN (EVPN/VXLAN), `ovs‑vsctl` only for OVS‑specific operations (mtu, patch/mirror, optional non‑EVPN vxlan), and **never** attempt node `/network type=vxlan`—EVPN fabric is **SDN‑driven** and renders as **Linux interfaces that FRR consumes**; **OVS is the access layer** glued via veth.

***

## 🔧 Variables (override in `group_vars/all.yml` as needed)

```yaml
# Bridges
vmbr_linux_gateway: "vmbr2"   # ExtBridge (Linux)
vmbr_ovs_tenant: "vmbr1"      # VMBridge (OVS)
vmbr_ovs_mgmt: "vmbr99"       # MgmtBridge (OVS)

# MTU discipline
mtu_linux_gateway: 1420       # WireGuard/EVPN path clamp

# Glue control (optional second pair to mgmt)
glue_to_mgmt: true

# Interface names (customize if you prefer different naming)
glue_vmbr1:
  veth_linux: "veth-linux-vmbr1"
  veth_ovs:   "veth-ovs-vmbr1"

glue_vmbr99:
  veth_linux: "veth-linux-vmbr99"
  veth_ovs:   "veth-ovs-vmbr99"
```

***

## ✅ Tasks: `roles/edgesec_sdn/tasks/establish_glue.yml`

```yaml
---
# Tags: establish_glue

- name: "DRIFT GUARD: Print pinned one-sentence rule"
  ansible.builtin.debug:
    msg: >-
      Use pvesh for node interfaces and SDN (EVPN/VXLAN), use ovs-vsctl only for
      OVS-specific operations (mtu, patch/mirror, optional non-EVPN vxlan), and never
      attempt node /network type=vxlan—the EVPN fabric is SDN-driven and renders as Linux
      interfaces that FRR consumes; OVS is the access layer glued via veth.
  tags: [establish_glue]

# -------------------------------
# Helper: existence checks (sysfs)
# -------------------------------
- name: "Check if vmbr2↔vmbr1 veth (Linux end) exists"
  ansible.builtin.stat:
    path: "/sys/class/net/{{ glue_vmbr1.veth_linux }}"
  register: glue_vmbr1_linux_stat

- name: "Check if vmbr2↔vmbr1 veth (OVS end) exists"
  ansible.builtin.stat:
    path: "/sys/class/net/{{ glue_vmbr1.veth_ovs }}"
  register: glue_vmbr1_ovs_stat

- name: "Check if vmbr2↔vmbr99 veth (Linux end) exists"
  ansible.builtin.stat:
    path: "/sys/class/net/{{ glue_vmbr99.veth_linux }}"
  register: glue_vmbr99_linux_stat
  when: glue_to_mgmt

- name: "Check if vmbr2↔vmbr99 veth (OVS end) exists"
  ansible.builtin.stat:
    path: "/sys/class/net/{{ glue_vmbr99.veth_ovs }}"
  register: glue_vmbr99_ovs_stat
  when: glue_to_mgmt

# -------------------------------
# Check-mode simulation
# -------------------------------
- name: "[CHECK] Simulate Glue creation plan"
  ansible.builtin.debug:
    msg:
      - "Would create veth pair {{ glue_vmbr1.veth_linux }} <-> {{ glue_vmbr1.veth_ovs }}; MTU={{ mtu_linux_gateway }}"
      - "Would enslave {{ glue_vmbr1.veth_linux }} to {{ vmbr_linux_gateway }} and add {{ glue_vmbr1.veth_ovs }} to {{ vmbr_ovs_tenant }}"
      - "{{ glue_to_mgmt | ternary('Would also create vmbr2↔vmbr99 glue with same MTU','Mgmt glue disabled') }}"
  when: ansible_check_mode

# -------------------------------
# vmbr2 ↔ vmbr1 glue (create if missing)
# -------------------------------
- name: "Create veth pair vmbr2↔vmbr1"
  ansible.builtin.command:
    cmd: >
      ip link add {{ glue_vmbr1.veth_linux }} type veth peer name {{ glue_vmbr1.veth_ovs }}
  when: not ansible_check_mode and (not glue_vmbr1_linux_stat.stat.exists) and (not glue_vmbr1_ovs_stat.stat.exists)
  changed_when: true

- name: "Set MTU on vmbr2↔vmbr1 veth ends"
  ansible.builtin.command:
    cmd: ip link set dev {{ item }} mtu {{ mtu_linux_gateway }}
  loop:
    - "{{ glue_vmbr1.veth_linux }}"
    - "{{ glue_vmbr1.veth_ovs }}"
  when: not ansible_check_mode
  changed_when: false

- name: "Enslave Linux end to {{ vmbr_linux_gateway }}"
  ansible.builtin.command:
    cmd: ip link set {{ glue_vmbr1.veth_linux }} master {{ vmbr_linux_gateway }}
  when: not ansible_check_mode
  changed_when: false

- name: "Bring up both veth ends (vmbr2↔vmbr1)"
  ansible.builtin.command:
    cmd: ip link set dev {{ item }} up
  loop:
    - "{{ glue_vmbr1.veth_linux }}"
    - "{{ glue_vmbr1.veth_ovs }}"
  when: not ansible_check_mode
  changed_when: false

- name: "Add OVS port on {{ vmbr_ovs_tenant }} for {{ glue_vmbr1.veth_ovs }} (idempotent)"
  ansible.builtin.command:
    cmd: >
      ovs-vsctl --may-exist add-port {{ vmbr_ovs_tenant }} {{ glue_vmbr1.veth_ovs }}
  when: not ansible_check_mode
  changed_when: true

- name: "Request OVS MTU (port) = {{ mtu_linux_gateway }}"
  ansible.builtin.command:
    cmd: >
      ovs-vsctl set Interface {{ glue_vmbr1.veth_ovs }} mtu_request={{ mtu_linux_gateway }}
  when: not ansible_check_mode
  changed_when: false

# -------------------------------
# vmbr2 ↔ vmbr99 glue (optional)
# -------------------------------
- name: "Create veth pair vmbr2↔vmbr99"
  ansible.builtin.command:
    cmd: >
      ip link add {{ glue_vmbr99.veth_linux }} type veth peer name {{ glue_vmbr99.veth_ovs }}
  when: glue_to_mgmt and not ansible_check_mode and (not glue_vmbr99_linux_stat.stat.exists) and (not glue_vmbr99_ovs_stat.stat.exists)
  changed_when: true

- name: "Set MTU on vmbr2↔vmbr99 veth ends"
  ansible.builtin.command:
    cmd: ip link set dev {{ item }} mtu {{ mtu_linux_gateway }}
  loop:
    - "{{ glue_vmbr99.veth_linux }}"
    - "{{ glue_vmbr99.veth_ovs }}"
  when: glue_to_mgmt and not ansible_check_mode
  changed_when: false

- name: "Enslave Linux end to {{ vmbr_linux_gateway }} (vmbr2↔vmbr99)"
  ansible.builtin.command:
    cmd: ip link set {{ glue_vmbr99.veth_linux }} master {{ vmbr_linux_gateway }}
  when: glue_to_mgmt and not ansible_check_mode
  changed_when: false

- name: "Bring up both veth ends (vmbr2↔vmbr99)"
  ansible.builtin.command:
    cmd: ip link set dev {{ item }} up
  loop:
    - "{{ glue_vmbr99.veth_linux }}"
    - "{{ glue_vmbr99.veth_ovs }}"
  when: glue_to_mgmt and not ansible_check_mode
  changed_when: false

- name: "Add OVS port on {{ vmbr_ovs_mgmt }} for {{ glue_vmbr99.veth_ovs }} (idempotent)"
  ansible.builtin.command:
    cmd: >
      ovs-vsctl --may-exist add-port {{ vmbr_ovs_mgmt }} {{ glue_vmbr99.veth_ovs }}
  when: glue_to_mgmt and not ansible_check_mode
  changed_when: true

- name: "Request OVS MTU (port) = {{ mtu_linux_gateway }} (vmbr99)"
  ansible.builtin.command:
    cmd: >
      ovs-vsctl set Interface {{ glue_vmbr99.veth_ovs }} mtu_request={{ mtu_linux_gateway }}
  when: glue_to_mgmt and not ansible_check_mode
  changed_when: false

# -------------------------------
# Validation (non-disruptive)
# -------------------------------
- name: "Validate veth presence and bindings"
  ansible.builtin.command: bash -lc "ip -d link show {{ glue_vmbr1.veth_linux }}; ip -d link show {{ glue_vmbr1.veth_ovs }}"
  register: glue_vmbr1_validate
  changed_when: false
  failed_when: false

- name: "Validate OVS ports"
  ansible.builtin.command: >
    ovs-vsctl list Interface {{ glue_vmbr1.veth_ovs }}
  register: glue_vmbr1_ovs_iface
  changed_when: false
  failed_when: false

- name: "Print validation summaries"
  ansible.builtin.debug:
    msg:
      - "vmbr2↔vmbr1 veth: {{ glue_vmbr1_validate.stdout | default('n/a') }}"
      - "OVS iface (vmbr1): {{ glue_vmbr1_ovs_iface.stdout | default('n/a') }}"
  when: not ansible_check_mode
```

***

## 🧪 Run examples

*   **Dry‑run (safe):**
    ```bash
    ansible-playbook -i inventory.ini ansible/provision.yml --check --tags establish_glue
    ```
*   **Apply just glue tasks:**
    ```bash
    ansible-playbook -i inventory.ini ansible/provision.yml --tags establish_glue
    ```

***

## 🧠 Notes & Good Practices

*   **MTU discipline**: We explicitly set **1420** on both veth ends and request **1420** on the OVS Interface to avoid fragmentation/blackholes along your WireGuard/EVPN path.
*   **Idempotency**: We probe **sysfs** (`/sys/class/net/...`) before creation and use `ovs-vsctl --may-exist add-port`.
*   **Check‑mode**: No interfaces or ports are created; you get a concise simulation via `debug`.
*   **Loops**: Maintain a **single veth path per OVS bridge**. Don’t cross-connect OVS bridges together through Linux in multiple places; if needed, enable RSTP on Linux bridges.
*   **Asym speeds**: `vmbr2` @ 10 GbE and OVS @ 1 GbE — veth clamps throughput to the slower side for flows that traverse the glue; east‑west inside `vmbr1` remains local and fast.

***

If you want, I can **add guards** to refuse creation when `vmbr2`, `vmbr1`, or `vmbr99` are missing (via `pvesh get ... --output-format json`) and print a meaningful error/simulation in `--check`.
