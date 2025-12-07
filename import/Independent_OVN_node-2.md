Proxmox VM integration with OVN (stage two)

This guide converts your initial OVN baseline into real VM connectivity by binding Proxmox tap interfaces to OVN logical ports, wiring the provider bridge, and validating end-to-end traffic.

1. Preconditions

OVN baseline is up: NB/SB on TCP, northd and controller running, br-int has flows.

Logical topology exists: Logical switches and router created (tenant1_mgmt, tenant1_engineering, tenant1_ext, tenant1-router).

Provider bridge wired: ovs2 attached to xg1, ovn-bridge-mappings="ovs2:ovs2", ovs2 has a reachable IP (e.g., 172.16.11.20/24), and upstream gateway responds.

2. Verify NB logical ports for the VMs

Confirm logical ports (names and MACs):

ovn-nbctl show

Identify the LSPs you will bind (example):

vm200 → MAC BC:24:11:AF:E3:71

vm201 → MAC BC:24:11:EC:0C:23

3. Boot the VMs on br-int

Start VMs in Proxmox (they already reference bridge=br-int):

qm start 200
qm start 201

Find tap device names (they’re created when VMs start):

ip link show | grep -E 'tap200|tap201|br-int'

Typical names: tap200i0, tap201i0.

4. Bind tap interfaces to OVN logical ports

Set external_ids on tap devices:

# VM 200
ovs-vsctl set interface tap200i0 \
  external_ids:iface-id=vm200 \
  external_ids:attached-mac="BC:24:11:AF:E3:71" \
  external_ids:iface-status=active

# VM 201
ovs-vsctl set interface tap201i0 \
  external_ids:iface-id=vm201 \
  external_ids:attached-mac="BC:24:11:EC:0C:23" \
  external_ids:iface-status=active

Verify bindings:

ovn-sbctl show
# Expect: Port_Binding vm200, Port_Binding vm201 under Chassis pve1

5. Configure tenant IPs inside the VMs

Assign IPs to match NB config:

# Inside VM 200
ip addr add 10.255.0.200/24 dev eth0
ip link set eth0 up

# Inside VM 201
ip addr add 10.255.0.201/24 dev eth0
ip link set eth0 up

Set default routes for outbound testing (optional if you’ll test only intra-tenant):

# VM 200
ip route add default via 10.255.0.1

# VM 201
ip route add default via 10.255.0.1

6. Functional tests

VM ↔ VM (same logical switch):

# From VM 200 to VM 201
ping -c 3 10.255.0.201

VM ↔ logical router:

# From VM 200
ping -c 3 10.255.0.1

VM ↔ external gateway via localnet uplink:

If tenant1_ext is connected to tenant1-router and uplink1 maps to ovs2:xg1, test from a VM on tenant1_ext (or create vm1-ext as a test interface):

# Option: create a test LSP on tenant1_ext and claim it temporarily
ovn-nbctl lsp-add tenant1_ext vm1-ext
ovn-nbctl lsp-set-addresses vm1-ext "50:54:00:00:00:03 172.16.11.30"

ovs-vsctl add-port br-int vmi3 -- \
  set interface vmi3 type=internal \
  external_ids:iface-id=vm1-ext \
  external_ids:attached-mac="50:54:00:00:00:03" \
  external_ids:iface-status=active
ip link set vmi3 up
ip addr add 172.16.11.30/24 dev vmi3

ping -c 3 172.16.11.1

7. Optional: SNAT for outbound

If upstream doesn’t route tenant subnets, masquerade them behind the router’s external IP:

ovn-nbctl -- --id=@nat create NAT type=snat \
  logical_ip="10.255.0.0/24" external_ip="172.16.11.20" \
  -- add Logical_Router tenant1-router nat @nat

Add default routes inside VMs:

ip route add default via 10.255.0.1

Test reachability to an upstream host:

ping -c 3 172.16.11.1

8. Clean up test internals (when moving to real VMs only)

If you created vmi1/vmi2/vmi3 for testing, you can remove them once real VMs are in place:

ip addr flush dev vmi1 2>/dev/null; ip link set vmi1 down; ovs-vsctl del-port br-int vmi1
ip addr flush dev vmi2 2>/dev/null; ip link set vmi2 down; ovs-vsctl del-port br-int vmi2
ip addr flush dev vmi3 2>/dev/null; ip link set vmi3 down; ovs-vsctl del-port br-int vmi3

9. Audit and verification

SB bindings:

ovn-sbctl list port_binding | grep -E 'vm200|vm201|uplink1'

br-int flows (output to xg1 ofport=1):

ovs-ofctl dump-flows br-int | grep 'output:1'

Provider path:

ip addr show ovs2
ip neigh show dev ovs2

OVN health:

ovn-sbctl show
ss -ltnp | grep -E '6641|6642'

If you want, I’ll package this into a single, parameterized script that:

Detects tap interfaces on br-int,

Matches them to NB logical ports by MAC,

Sets external_ids,

Optionally adds SNAT,

Prints a concise audit of bindings and flows.