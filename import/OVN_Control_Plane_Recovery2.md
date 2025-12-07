# OVN Control-Plane Recovery (Post-Mortem & Actions)

This document records the recovery steps taken to restore OVN control-plane function and to allow the host (10.255.0.1) to reach VM200 (10.255.0.200) while preserving `vmbr1` as a Linux bridge. It lists diagnostics, commands used, artifacts collected, what was changed, and recommended next steps.

## Summary

- Problem: OVN controller could not register due to a stale duplicate SB Encap row; additionally `localnet-physnet1` (provider localnet) did not flip `up:true` automatically and dataplane replies from VM200 were not reaching the host kernel.
- Goal: Restore controller registration, make OVN manage `br-int`, preserve `vmbr1`, and ensure host → VM200 connectivity. Temporary dataplane flows were used until OVN-managed dataplane was healthy.

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

6. Restarted/started OVN components (used packaged `ovn-ctl` scripts where appropriate) and ensured the host chassis registered in the SB DB.
7. Observed Port_Binding for `localnet-physnet1` existed but `up:false`. When the controller did not set `up:true` automatically, the chassis and `up` fields were set via a controlled write to SB Port_Binding (forcing the binding) to recover dataplane wiring.
8. While the provider bridge LOCAL port was in `LINK_DOWN` state (preventing the normal OVN dataplane path), temporary OpenFlow rules were added on `br-int` to forward traffic for `10.255.0.200` to the VM tap and to return replies to the host kernel.

Examples of temporary flows installed (what was executed):

```bash
# forward host->VM
ovs-ofctl add-flow br-int "priority=300,arp,arp_tpa=10.255.0.200 actions=output:tap200i0"
ovs-ofctl add-flow br-int "priority=300,ip,nw_dst=10.255.0.200 actions=output:tap200i0"

# return-path VM->host (tap -> LOCAL)
ovs-ofctl add-flow br-int "priority=310,in_port=tap200i0,arp,arp_spa=10.255.0.200,arp_tpa=10.255.0.1 actions=LOCAL"
ovs-ofctl add-flow br-int "priority=310,in_port=tap200i0,ip,nw_src=10.255.0.200 actions=LOCAL"
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
ovs-ofctl add-flow br-int 'priority=310,in_port=LOCAL,arp,arp_spa=10.255.0.1,arp_tpa=10.255.0.201 actions=output:tap201i0'
ovs-ofctl add-flow br-int 'priority=310,in_port=LOCAL,ip,nw_dst=10.255.0.201 actions=output:tap201i0'

# return-path VM->host (tap -> LOCAL)
ovs-ofctl add-flow br-int 'priority=310,in_port=tap201i0,arp,arp_spa=10.255.0.201,arp_tpa=10.255.0.1 actions=LOCAL'
ovs-ofctl add-flow br-int 'priority=310,in_port=tap201i0,ip,nw_src=10.255.0.201 actions=LOCAL'
```

4) Verify flows, traces, neighbor table and connectivity:

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
ovs-ofctl add-flow br-int 'priority=310,in_port=tap200i0,arp,arp_spa=10.255.0.200,arp_tpa=10.255.0.1 actions=LOCAL'
ovs-ofctl add-flow br-int 'priority=310,in_port=tap200i0,ip,nw_src=10.255.0.200 actions=LOCAL'
ovs-ofctl --names dump-flows br-int | head -n 60
ping -c3 -W2 10.255.0.200
```

## Observations & Current State

- Controller registration: successful after removing duplicate Encap and restarting controller.
- `veth-prov` now has `external_ids: iface-id=localnet-physnet1, iface-id-ver="1", iface-status=active`.
- Port_Binding (UUID 404bf0eb) shows `chassis` assigned to local host and `up:true` (forced when controller did not flip automatically).
- Temporary flows enabled on `br-int` forwarded packets correctly; VM replies were visible on the VM tap and, with the return-path flows, reached the host kernel—pings succeeded.
- Remaining issue: `br-provider` LOCAL port reported `LINK_DOWN` / `PORT_DOWN` in `ovs-ofctl show br-provider`. While temporary flows restore connectivity, OVN will not manage the dataplane correctly until the provider bridge local path is healthy and OVN installs its permanent flows.

Additional, recent verification (post-reboot):

- `br-int` initially had no IPv4 address configured; I temporarily added the host address `10.255.0.1/24` to `br-int` to allow ARP resolution from the host kernel. Command used:

```bash
ip addr add 10.255.0.1/24 dev br-int
```

- I captured ARP/ICMP on `br-int` and inspected flow/port counters: repeated ARP requests from VM `bc:24:11:af:e3:71` were observed. After assigning `10.255.0.1/24`, host ping to `10.255.0.200` succeeded (3/3), and `ip neigh` shows `10.255.0.200 REACHABLE`.
- The temporary `br-int` OpenFlow rules (forward + return) show non-zero packet counters, confirming they are matching traffic and providing the working dataplane while `br-provider` LOCAL remains down.

## Next Steps / Recommendations

1. Repair `br-provider` LOCAL link (investigate why LOCAL is LINK_DOWN). Typical checks:

```bash
ovs-ofctl show br-provider
ovs-vsctl list interface
ip link show br-provider
ethtool <provider-phys-if>  # if applicable
```

2. Once `br-provider` LOCAL is UP, restart `ovn-controller` (or trigger recompute) and verify that OVN installs permanent datapath flows and that Port_Binding changes are reflected by OVN flow programming.

3. After OVN-managed flows are present and verified, remove the temporary flows from `br-int`:

```bash
ovs-ofctl del-flows br-int "in_port=tap200i0,arp,arp_spa=10.255.0.200,arp_tpa=10.255.0.1"
ovs-ofctl del-flows br-int "in_port=tap200i0,ip,nw_src=10.255.0.200"
ovs-ofctl del-flows br-int "ip,nw_dst=10.255.0.200"  # if still present
```

Note: because the temporary flows are currently matching traffic (counters observed), you can remove them immediately only if OVN has already installed equivalent permanent flows. If not, removing them will disrupt host↔VM connectivity; consider repairing `br-provider` and forcing a controller recompute first.

4. Validate end-to-end: clear host ARP cache, confirm `ip neigh` for 10.255.0.200 is reachable, and run ping/traceroute. Confirm NB/SB Port_Binding `up:true` remains without manual forcing.

5. Consider adding a small playbook or idempotent script to:

 - Collect relevant diagnostics to `/tmp/ovn_recovery_auto/` (NB/SB dumps, flows, ovs external_ids).
 - Safely check and remove duplicate SB Encap rows (but require operator confirmation).
 - Annotate the provider interface and validate binding state.

## Notes / Warnings

- The temporary OpenFlow rules installed are high-priority and bypass the normal OVN pipeline; do not leave them enabled in production beyond the recovery window.
- Forcing `Port_Binding.up=true` and setting `chassis` manually is a recovery action—prefer allowing OVN to set these automatically once controller and interface state are healthy.

---
_Document created programmatically as `OVN_Control_Plane_Recovery2.md` to capture recovery steps, artifacts, and next steps. If you want, I can (A) attempt to repair `br-provider` LOCAL link now, (B) remove the temporary flows, or (C) prepare an ansible playbook to automate verification and cleanup._
