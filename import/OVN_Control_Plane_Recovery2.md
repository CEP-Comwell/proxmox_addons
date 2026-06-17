# OVN Control-Plane Recovery (Post-Mortem & Actions)

This document records the recovery steps taken to restore OVN control-plane function and to allow the host (10.255.0.1) to reach VM200 (10.255.0.200) while preserving `vmbr1` as a Linux bridge. It lists diagnostics, commands used, artifacts collected, what was changed, and recommended next steps.

## Summary

- Problem: OVN controller could not register due to a stale duplicate SB Encap row; additionally `localnet-physnet1` (provider localnet) did not flip `up:true` automatically and dataplane replies from VM200 were not reaching the host kernel.
- Goal: Restore controller registration, make OVN manage `br-int`, preserve `vmbr1`, and ensure host → VM200 connectivity. Temporary dataplane flows were used until OVN-managed dataplane was healthy. Extended to enable external (172.16.11.10) → VM connectivity. Revised to use OVS bridges (ovs1) for OVN, connected via veth to vmbr1 with xg1.
- Current Setup: Bridge-mappings set to physnet1:ovs1. ovs1 connected to vmbr1 via veth pair (veth-prov on ovs1, vethlnet on vmbr1). xg1 on vmbr1. Temporary flows on br-int for host and external traffic. LOCAL on ovs1 remains LINK_DOWN, preventing permanent OVN flows, but temp flows provide connectivity.

## Artifacts & Diagnostic Files

- Diagnostics saved under: `/tmp/ovn_recovery_auto/` (NB/SB dumps, `br-int.flows`, `ovn-controller.fg.log`, tcpdumps, etc.)
- Additional capture tarball and extracted capture used during validation: `tmp/ovn_capture_now_1764919280/` (pcaps and extracted text).

Key files (examples):
- `/tmp/ovn_recovery_auto/ovn-controller.fg.log`
- `/tmp/ovn_recovery_auto/br-int.flows`
- `/tmp/ovn_recovery_auto/nb_dump.json`
- `/tmp/ovn_recovery_auto/sb_dump.json`
- `/tmp/ovn_recovery_auto/capture_*.pcap`

## Timeline of Actions (concise)

1. Collected diagnostics (NB/SB dumps, `ovs-vsctl` external_ids, interface lists, `br-int` flows, packet captures).
2. Found and removed stale duplicate SB Encap row that caused controller registration constraint errors.
3. Set OVS external_ids (encap, bridge-mappings):

```bash
ovs-vsctl set Open_vSwitch . \ 
  external_ids:ovn-encap-type=geneve \ 
  external_ids:ovn-encap-ip=172.16.11.20 \ 
  external_ids:ovn-bridge-mappings="physnet1:br-provider"
```

4. Created `br-provider` and linked a veth pair so `vmbr1` remained untouched.
5. Annotated provider-side interface with the iface-id expected by OVN:

```bash
ovs-vsctl set Interface veth-prov external_ids:iface-id=localnet-physnet1 \
  external_ids:iface-id-ver=1 external_ids:iface-status=active
ovs-vsctl remove Interface vethlnet external_ids iface-id || true
```

6. Started OVN central DB servers (ovn-ovsdb-server-nb and ovn-ovsdb-server-sb) as they were masked but needed for database access.
7. Restarted/started OVN components (used packaged `ovn-ctl` scripts where appropriate) and ensured the host chassis registered in the SB DB.
8. Observed Port_Binding for `localnet-physnet1` existed but `up:false`. When the controller did not set `up:true` automatically, the chassis and `up` fields were set via a controlled write to SB Port_Binding (forcing the binding) to recover dataplane wiring.
9. While the provider bridge LOCAL port was in `LINK_DOWN` state (preventing the normal OVN dataplane path), temporary OpenFlow rules were added on `br-int` to forward traffic for `10.255.0.200` and `10.255.0.201` to the VM taps and to return replies to the host kernel.

Examples of temporary flows installed (what was executed):

```bash
# forward host->VM
ovs-ofctl add-flow br-int "priority=2000,arp,arp_tpa=10.255.0.200 actions=output:tap200i0"
ovs-ofctl add-flow br-int "priority=2000,ip,nw_dst=10.255.0.200 actions=output:tap200i0"

# return-path VM->host (tap -> LOCAL)
ovs-ofctl add-flow br-int "priority=2000,in_port=tap200i0,arp,arp_spa=10.255.0.200,arp_tpa=10.255.0.1 actions=LOCAL"
ovs-ofctl add-flow br-int "priority=2000,in_port=tap200i0,ip,nw_src=10.255.0.200 actions=LOCAL"
```

9. Validated via tcpdump on `tap200i0` that the VM responded (ARP replies, ICMP echo replies). After adding the return-path flows the host ping to 10.255.0.200 succeeded (3/3 packets).

## Commands Run (representative)

- Inspect OVS external IDs and interfaces:

```bash
ovs-vsctl get Open_vSwitch . external_ids
ovs-vsctl list Interface
ovs-vsctl show
```

- NB/SB dumps and captures (examples):

```bash
ovn-nbctl --if-exists show > /tmp/ovn_recovery_auto/nb_dump.txt
ovn-sbctl --if-exists show > /tmp/ovn_recovery_auto/sb_dump.txt
ovs-ofctl --names dump-flows br-int > /tmp/ovn_recovery_auto/br-int.flows
tcpdump -nn -i tap200i0 -c 200 host 10.255.0.200 -w /tmp/ovn_recovery_auto/capture_tap200.pcap
```

## VM201 — OVN registration & temporary dataplane flows (usage examples)

The following commands show the exact sequence used to register `vm201` with OVN, annotate the tap interface, add temporary `br-int` forward+return flows (same pattern used for `vm200`), and verify connectivity from the host.

1) Add VM logical-port addresses and port-security in the NB:

```bash
ovn-nbctl lsp-set-addresses vm201 'BC:24:11:EC:0C:23 10.255.0.201'
ovn-nbctl lsp-set-port-security vm201 'BC:24:11:EC:0C:23 10.255.0.201'
```

2) Annotate the host `tap` so `ovn-controller` can bind it:

```bash
ovs-vsctl set Interface tap201i0 \
  external_ids:iface-id=vm201 \
  external_ids:attached-mac="BC:24:11:EC:0C:23" \
  external_ids:iface-status=active

# verify
ovs-vsctl list Interface tap201i0
ovn-sbctl list Port_Binding | egrep -i 'vm201|vm200' -A3
```

3) (Recovery-only) Add temporary high-priority flows on `br-int` to forward host→VM and return VM→LOCAL so the host can ARP/communicate while the provider path is repaired:

```bash
# forward host->VM
ovs-ofctl add-flow br-int 'priority=2000,in_port=LOCAL,arp,arp_tpa=10.255.0.201 actions=output:tap201i0'
ovs-ofctl add-flow br-int 'priority=2000,in_port=LOCAL,ip,nw_dst=10.255.0.201 actions=output:tap201i0'

# return-path VM->host (tap -> LOCAL)
ovs-ofctl add-flow br-int 'priority=2000,in_port=tap201i0,arp,arp_spa=10.255.0.201,arp_tpa=10.255.0.1 actions=LOCAL'
ovs-ofctl add-flow br-int 'priority=2000,in_port=tap201i0,ip,nw_src=10.255.0.201 actions=LOCAL'
```

4) For external connectivity (from 172.16.11.10), add flows for traffic from patch port (port 13):

```bash
# forward external->VM
ovs-ofctl add-flow br-int 'priority=2000,in_port=13,arp,arp_tpa=10.255.0.201 actions=output:tap201i0'
ovs-ofctl add-flow br-int 'priority=2000,in_port=13,ip,nw_dst=10.255.0.201 actions=output:tap201i0'

# return-path VM->external
ovs-ofctl add-flow br-int 'priority=2000,in_port=tap201i0,arp,arp_spa=10.255.0.201 actions=output:13'
ovs-ofctl add-flow br-int 'priority=2000,in_port=tap201i0,ip,nw_src=10.255.0.201 actions=output:13'
```

5) On the external machine (172.16.11.10), add routes:

```bash
sudo ip route add 10.255.0.0/24 via 172.16.11.20
```

6) Verify flows, traces, neighbor table and connectivity:

```bash
ovs-ofctl --names dump-flows br-int | egrep -i '10.255.0.201|bc:24:11:ec:0c:23'
ovs-appctl ofproto/trace br-int 'in_port=LOCAL,arp,arp_spa=10.255.0.1,arp_tpa=10.255.0.201'
ovs-appctl ofproto/trace br-int 'in_port=LOCAL,ip,nw_dst=10.255.0.201'
ip -4 neigh show dev br-int
ping -c3 -W2 10.255.0.201
```

5) Cleanup / follow-up:

- After the provider `br-provider` LOCAL link is repaired and `ovn-controller` programs permanent flows, remove the temporary flows (or delete only the exact matches by match fields/cookie):

```bash
ovs-ofctl del-flows br-int "in_port=tap201i0,arp,arp_spa=10.255.0.201,arp_tpa=10.255.0.1"
ovs-ofctl del-flows br-int "in_port=tap201i0,ip,nw_src=10.255.0.201"
ovs-ofctl del-flows br-int "ip,nw_dst=10.255.0.201"
```

If OVN has not installed permanent flows after `ovn-controller` recompute, inspect `/var/log/ovn/ovn-controller.log` and force a recompute (restart `ovn-controller` or trigger OVS/OVN reconfiguration) and re-check `ovs-ofctl dump-flows br-int`.


## VM202 — Temporary dataplane flows applied

Similar to vm200 and vm201, vm202 (10.101.10.52) had OVN-installed flows but ping from host failed due to the br-provider LOCAL LINK_DOWN issue. Temporary high-priority flows were added to restore connectivity.

1) Verify VM registration and interface:

```bash
ovn-nbctl show | grep -A5 vm202
ovs-vsctl list Interface tap202i0
ovs-ofctl dump-flows br-int | grep 10.101.10.52
```

2) Ensure host IP on br-int:

```bash
ip addr add 10.101.10.1/24 dev br-int  # if not present
```

3) Add temporary flows:

```bash
# forward host->VM
ovs-ofctl add-flow br-int 'priority=2000,in_port=LOCAL,arp,arp_tpa=10.101.10.52 actions=output:tap202i0'
ovs-ofctl add-flow br-int 'priority=2000,in_port=LOCAL,ip,nw_dst=10.101.10.52 actions=output:tap202i0'

# return-path VM->host
ovs-ofctl add-flow br-int 'priority=2000,in_port=tap202i0,arp,arp_spa=10.101.10.52 actions=LOCAL'
ovs-ofctl add-flow br-int 'priority=2000,in_port=tap202i0,ip,nw_src=10.101.10.52 actions=LOCAL'
```

4) For external connectivity (from 172.16.11.10), add flows for traffic from patch port (port 13):

```bash
# forward external->VM
ovs-ofctl add-flow br-int 'priority=2000,in_port=13,arp,arp_tpa=10.101.10.52 actions=output:tap202i0'
ovs-ofctl add-flow br-int 'priority=2000,in_port=13,ip,nw_dst=10.101.10.52 actions=output:tap202i0'

# return-path VM->external
ovs-ofctl add-flow br-int 'priority=2000,in_port=tap202i0,arp,arp_spa=10.101.10.52 actions=output:13'
ovs-ofctl add-flow br-int 'priority=2000,in_port=tap202i0,ip,nw_src=10.101.10.52 actions=output:13'
```

5) On the external machine (172.16.11.10), add routes:

```bash
sudo ip route add 10.101.10.0/24 via 172.16.11.20
```

6) Verify connectivity:

```bash
ping -I br-int -c3 10.101.10.52  # host ping
ping 10.101.10.52  # external ping
```

5) For external connectivity, ensure DHCP options include router=10.101.10.1 for the 10.101.10.0/24 subnet. If missing, set with:

```bash
ovn-nbctl dhcp-options-set-options <uuid> router=10.101.10.1 server_id=10.101.10.1
ovn-nbctl set logical_switch_port dhcp-vx10110 dhcpv4_options=<uuid>
```

Where <uuid> is the DHCP options with router and server_id.

If port security blocks DHCP, temporarily clear it: `ovn-nbctl clear logical_switch_port vm202 port_security`

Then renew DHCP in the VM to apply.

Note: If Port_Binding chassis is not set for VMs, manually set it:

```bash
ovn-sbctl set Port_Binding <vm> chassis=<chassis-uuid>
```

Where chassis-uuid is from `ovn-sbctl show`.

Temporary flows for vm202 were re-added after manual IP assignment to restore connectivity.

DHCP setup: Cleared port security for vm202, set chassis for vm202 by annotating tap202i0 with external_ids and restarting ovn-controller. Added temp flows for DHCP UDP traffic. Set up=true for dhcp-vx10110. DHCP still not working, so set vm202 to static IP 10.101.10.52/24,gw=10.101.10.1 as workaround.

Investigation into DHCP failure: The netplan configuration on vm202 (Ubuntu 24.04 LTS cloud-init image) is generated by cloud-init based on the Proxmox VM ipconfig0 setting. When set to static, netplan uses static IP. The DHCP client used is systemd-networkd, which is standard for Ubuntu 24.04 and does not use a different package. The issue was that temporary OpenFlow rules added for connectivity included ARP and IP forwarding but not UDP for DHCP (ports 67/68). DHCP requests from the VM were not forwarded to the OVN controller, preventing the DHCP server from responding. Temporary UDP flows have been added to enable DHCP if the VM config is changed to ip=dhcp.

Further investigation: DHCP timeout at systemd-networkd startup was due to the Port_Binding for vm202 not having chassis set in the SB database. Without chassis assigned, ovn-controller does not install DHCP flows for the VM. After setting chassis=dd684626-5682-4a5f-932f-12e38defc790 and up=true for vm202, and restarting ovn-controller, OVN should install the necessary DHCP flows. The VM was reset to static IP to restore access. To enable DHCP, set ipconfig0 to ip=dhcp and reboot the VM; it should now obtain an IP from OVN DHCP server.

Post-reboot connectivity issue: After rebooting vm202 with static IP, ping to gateway failed because temporary OpenFlow rules were lost (likely due to OVS restart). Re-added priority 2000 flows on br-int for vm202 (port 26): ARP and IP forwarding from LOCAL to tap202i0, and return flows from tap202i0 to LOCAL. Host-to-VM ping now works; VM-to-gateway ping should be restored.

DHCP Resolution for vm202: Set ipconfig0 to ip=dhcp and rebooted VM. With chassis=dd684626-5682-4a5f-932f-12e38defc790 and up=true set in Port_Binding, OVN should install DHCP flows upon VM startup. DHCP options configured with router=10.101.10.1, server_id=10.101.10.1. Port security cleared. VM should obtain 10.101.10.52 via DHCP. If successful, remove IP-specific temp flows and rely on OVN flows.


- Remove stale SB Encap row (example invocation used interactively):

```bash
# list
ovn-sbctl list Encapsulation
# remove duplicate (example)
ovn-sbctl --if-exists remove Encapsulation <uuid>
```

- Port_Binding forced update (example):

```bash
# This was performed via ovn-sbctl transaction to set chassis and up=true
ovn-sbctl set Port_Binding 404bf0eb chassis=3bdde6d3-... up=true
```

- Temp flows and verification:

```bash
ovs-ofctl add-flow br-int 'priority=2000,in_port=tap200i0,arp,arp_spa=10.255.0.200,arp_tpa=10.255.0.1 actions=LOCAL'
ovs-ofctl add-flow br-int 'priority=2000,in_port=tap200i0,ip,nw_src=10.255.0.200 actions=LOCAL'
ovs-ofctl --names dump-flows br-int | head -n 60
ping -c3 -W2 10.255.0.200
```

## Observations & Current State

- Controller registration: successful after removing duplicate Encap and restarting controller.
- `veth-prov` now has `external_ids: iface-id=localnet-physnet1, iface-id-ver="1", iface-status=active`.
- Port_Binding (UUID 404bf0eb) shows `chassis` assigned to local host and `up:true` (forced when controller did not flip automatically).
- Temporary flows enabled on `br-int` forwarded packets correctly for vm200, vm201, and vm202; VM replies were visible on the VM taps and, with the return-path flows, reached the host kernel—pings succeeded. Extended flows for external traffic from patch port (13) enable ping from 172.16.11.10 to VMs, provided routes are added on the external machine and packets reach br-int. Priority 2000 was required to bypass interfering OVN flows.
- Remaining issue: `ovs1` LOCAL port reported `LINK_DOWN` / `PORT_DOWN` in `ovs-ofctl show ovs1`. While temporary flows restore connectivity, OVN will not manage the dataplane correctly until the provider bridge local path is healthy and OVN installs its permanent flows. The localnet interface for physnet1 is not created on ovs1, despite correct mappings and chassis binding.
- Remaining issue: `br-provider` LOCAL port reported `LINK_DOWN` / `PORT_DOWN` in `ovs-ofctl show br-provider`. While temporary flows restore connectivity, OVN will not manage the dataplane correctly until the provider bridge local path is healthy and OVN installs its permanent flows. Attempts to move the physical interface (xg1) to `br-provider` did not resolve the LOCAL LINK_DOWN state.

Additional, recent verification (post-reboot):

- `br-int` initially had no IPv4 address configured; I temporarily added the host address `10.255.0.1/24` to `br-int` to allow ARP resolution from the host kernel. Command used:

```bash
ip addr add 10.255.0.1/24 dev br-int
```

- I captured ARP/ICMP on `br-int` and inspected flow/port counters: repeated ARP requests from VM `bc:24:11:af:e3:71` were observed. After assigning `10.255.0.1/24`, host ping to `10.255.0.200` succeeded (3/3), and `ip neigh` shows `10.255.0.200 REACHABLE`.
- The temporary `br-int` OpenFlow rules (forward + return) show non-zero packet counters, confirming they are matching traffic and providing the working dataplane while `br-provider` LOCAL remains down.

## Next Steps / Recommendations

1. Network interface configurations added for ovs1 and ovs99 in /etc/network/interfaces.d/ to ensure bridges are properly managed by Proxmox networking.

2. External ping issue resolved: Packets from 172.16.11.10 reach br-int, but OVN flows were interfering. Re-added temporary flows with priority 400 to bypass OVN and enable ping from external to VMs.

3. Maintain temporary OpenFlow rules for vm200, vm201, and vm202 as the working dataplane solution. Monitor for OVN updates or alternative configurations.

4. To fix `ovs1` LOCAL LINK_DOWN and enable permanent OVN flows:
   - With interface configs added, reboot or restart networking to apply.
   - Investigate why localnet-physnet1 interface is not created on ovs1 despite mappings physnet1:ovs1 and chassis binding.
   - Check ovn-northd logs or force recompute.
   - Ensure veth-prov has carrier (check `ip link show veth-prov` for LOWER_UP).

5. Once `ovs1` LOCAL is UP, restart `ovn-controller` (or trigger recompute) and verify that OVN installs permanent datapath flows and that Port_Binding changes are reflected by OVN flow programming.

6. After OVN-managed flows are present and verified, remove the temporary flows from `br-int` (see commands in previous section).

## Notes / Warnings

- The temporary OpenFlow rules installed are high-priority and bypass the normal OVN pipeline; do not leave them enabled in production beyond the recovery window. They were applied to vm200, vm201, and vm202 to restore connectivity.
- Forcing `Port_Binding.up=true` and setting `chassis` manually is a recovery action—prefer allowing OVN to set these automatically once controller and interface state are healthy.
- The veth pair approach to preserve `vmbr1` as a Linux bridge works for connectivity but may prevent OVN from fully managing the dataplane due to `br-provider` LOCAL LINK_DOWN. Monitor for better integration methods.

---
_Document updated to include starting OVN DB servers, application of temporary flows to vm201 and vm202, and attempts to resolve br-provider LOCAL LINK_DOWN. Temporary flows provide working connectivity for vm200, vm201, and vm202 while awaiting permanent OVN dataplane management._
