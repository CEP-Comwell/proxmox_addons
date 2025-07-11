# Proxmox VM Traffic Mirroring with Ansible

**Description**

This Ansible playbook is designed to mirror VM traffic from (`vmbr0`) to (`brdpi`) using a veth interface (`veth0`) and tc (traffic control).
to mirror egress traffic from each VM's TAP interface.


**mirror_vmbr0_to_brdpi.yml**

* The playbook assumes that the veth interfaces (`veth0`) and its peer (`veth1`) have been manually set up and configured on the Proxmox host, as direct changes to `/etc/network/interfaces` are not recommended.

   

# Create veth pair
**Example file /etc/network/interfaces.d/edgesec.conf**

  ```bash
 auto veth0
iface veth0 inet manual
        pre-up ip link delete veth0 type veth || true
        pre-up ip link add veth0 type veth peer name veth1
        up ip link set veth0 up promisc on
        down ip link delete veth0

# Bring up veth1
auto veth1
iface veth1 inet manual
        up ip link set veth1 up promisc on

# Bridge interface for DPI monitoring

auto brdpi
iface brdpi inet manual
	bridge-ports veth1
	bridge-stp off
	bridge-fd 0
        pre-up ip link set brdpi promisc on
        post-down ip link set brdpi promisc off 
  ```
# Description

* The playbook defines several variables, including `dest_bridge`, `mirror_target`, `tap_prefix`, and `monitor_vm_ids`.
* The playbook includes several tasks, including:
	+ Discovering tap interfaces dynamically using `tasks/tap-discover.yml`, which takes advantage of the fact that Proxmox automatically creates tap interfaces associated with each VM ID.
	+ Debugging the list of discovered tap interfaces.
	+ Skipping mirroring setup if no tap interfaces are found.
	+ Applying mirroring to each tap interface using `tasks/mirror-task.yml`.

**tasks/tap-discover.yml**

* This subtask discovers tap interfaces dynamically, leveraging the fact that Proxmox automatically creates tap interfaces associated with each VM ID.

**tasks/mirror-task.yml**

* This subtask configures traffic mirroring from a given tap interface (`tap_if`) to the designated mirror target interface (`mirror_target`), typically `veth0`.
* The subtask ensures the tap interface is up, adds an ingress qdisc to the tap interface, checks if a `tc` mirror filter already exists, and adds a `tc` mirror filter to mirror traffic to the mirror target.
* The subtask also displays active `tc` filters on the tap interface.

---

## 📦 Features

- Dynamically discovers TAP interfaces (e.g., `tap400i0`)
- Excludes monitoring VMs by VMID
- Applies `tc` mirroring rules to forward traffic to `veth0`
- Designed for Proxmox 8.x

---

## 🛠 Requirements

- Ansible installed on your control node
- SSH access to Proxmox host(s)
- `tc` available on the Proxmox host
- Monitoring VM connected to the `brdpi` bridge

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/CEP-Comwell/proxmox_addons.git
cd proxmox_addons
```

**Usage**
To run the playbook, use the following command:

```bash
ansible-playbook -i inventory mirror_vmbr0_to_brdpi.yml
```

Replace inventory with the path to your Ansible inventory file.


