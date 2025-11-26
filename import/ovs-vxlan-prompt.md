## ✅ Meta-Prompt for LLM Coding Assistant

### **Goal**

MANDATE unique methods for managing OVS bridge interfaces and vxlan's within a custom ovs-vxlan method:

1. ovs bridges must be assigned directly using `/etc/network/interfaces` 
2. VXLAN tunnels must be assigned dynamically using `ovs-vsctl`. 

***

### Requirements

* Use clear headings and code blocks.
* Show both persistent OVS bridge configuration and dynamic VXLAN creation.
* Include IP assignment, MTU settings, verification commands and cautionary notes about persistence.

### Output Structure

# Managing OVS Bridges and VXLAN tunnels separately

## 1. Persistent OVS Bridge via /etc/network/interfaces

To ensure the OVS bridge comes up at boot with its IP and MTU, define it in `/etc/network/interfaces`. You must define each vxlan interface as attached to the ovs bridge at the time you create the ovs bridge interface.  Persisted files should contain declarative stanzas only — do not embed runtime `ovs-vsctl` commands.

ovs_bridge example: 

auto eth1
iface eth1 inet manual
        ovs_type OVSPort
        ovs_bridge vmbr1

auto vmbr1
iface vmbr1 inet static
        address 10.255.0.18/28
        ovs_type OVSBridge
        ovs_ports eth1 vx10110
        ovs_options fail_mode=standalone
        mtu 9000
```

Apply changes with care (test with `--check` first):

```bash
ifreload -a   # or use targeted ifup/ifdown for specific files
```

---

## 2. Dynamic VXLAN Creation with `ovs-vsctl` (runtime)

Create VXLAN interfaces at runtime using `ovs-vsctl`. Gate runtime creation with an Ansible boolean such as `ovs_create` so it only runs when explicitly requested.

Idempotent CLI example:

```bash
if ! ovs-vsctl list Interface vx10110 >/dev/null 2>&1; then
    ovs-vsctl add-port vmbr1 vx10110 -- \
        set interface vx10110 type=vxlan \
        options:key=10110 options:remote_ip=10.255.0.3 \
        options:dst_port=4789
fi
```

Idempotent Ansible task (use when `ovs_create: true`):

```yaml
- name: ensure vxlan interface exists on vmbr1
    shell: |
        if ! ovs-vsctl list Interface vx10110 >/dev/null 2>&1; then
            ovs-vsctl add-port vmbr1 vx10110 -- set interface vx10110 type=vxlan options:key=10110 options:remote_ip=10.255.0.3 options:dst_port=4789
        fi
    args:
        warn: false
    become: true
    when: ovs_create | bool
```

Order matters: ensure the bridge exists (or the persistent fragment is written) before attempting to add the VXLAN port.

---

## 3. Verification

Check OVS and interface state:

```bash
ovs-vsctl show
ovs-vsctl list Interface vx10110
ip link show vmbr1
ifquery vmbr1 || true
```

Expected (example) output for the interface:

        type: vxlan
        options: { key=10110, remote_ip="10.255.0.3", dst_port="4789" }

---

## 4. Persistence and restore options

OVS DB may persist ports across reboots, but ` /etc/network/interfaces` controls what `ifup`/`ifreload` brings up at boot. Test your full boot workflow.

Optional: export/restore OVS config if you want an OVS-level snapshot:

```bash
ovs-vsctl show > /etc/openvswitch/initial.conf
ovs-vsctl --no-wait --restore < /etc/openvswitch/initial.conf
```

Or create a small systemd unit to reapply runtime objects at boot if you prefer deterministic restore.

## 5. Best Practices

* Prefer short interface names (≤8 chars).
* OVS bridge and vxlan interfaces should be set MTU 9000
* Pass booleans to Ansible as JSON/YAML (example above) to avoid string-boolean parsing issues.
* Keep persistent fragments declarative and use `ovs_create` to control runtime modifications.
