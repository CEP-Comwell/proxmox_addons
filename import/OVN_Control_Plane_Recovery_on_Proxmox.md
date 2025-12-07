OVN control plane recovery and binding checklist on Proxmox

This is a consolidated, proven sequence to recover OVN NB/SB, align ovn-controller, and ensure VM ports bind correctly on Proxmox. It accounts for Proxmox packaging quirks, avoids mixing service managers, and keeps the setup stable across reboots.

Prerequisites and naming

Switch/router/ports: sw1, lr0, sw1-lr0, lr0-sw1, vm200, vm201

MACs: VM200 BC:24:11:AF:E3:71; VM201 BC:24:11:EC:0C:23

Router MAC: 00:00:00:aa:bb:cc

Geneve chassis IP: 172.16.10.20 on pve1

Avoid renaming; these match bindings and audit artifacts.

1. Start OVN databases and controller with ovn-ctl

Do not mix systemctl and ovn-ctl for the same daemon. Use ovn-ctl to manage OVN components; use systemctl only for Open vSwitch.

# Start NB/SB OVSDB servers
/usr/share/ovn/scripts/ovn-ctl start_ovsdb

# Start northd (translator NB→SB)
/usr/share/ovn/scripts/ovn-ctl start_northd

# Start controller (per chassis)
/usr/share/ovn/scripts/ovn-ctl start_controller

Verify sockets:

ls -l /var/run/ovn/
# Expect: ovnnb_db.sock, ovnsb_db.sock, ovn-controller.pid (running)

If the controller complains about an existing PID, stop duplicates:

pkill -f ovn-controller
rm -f /var/run/ovn/ovn-controller.pid
/usr/share/ovn/scripts/ovn-ctl start_controller

2. Point Open vSwitch to local OVN sockets

Ensure OVS knows where NB/SB live and where the SB remote is:

ovs-vsctl set Open_vSwitch . external_ids:ovn-nb="unix:/var/run/ovn/ovnnb_db.sock"
ovs-vsctl set Open_vSwitch . external_ids:ovn-sb="unix:/var/run/ovn/ovnsb_db.sock"
ovs-vsctl set Open_vSwitch . external_ids:ovn-remote="unix:/var/run/ovn/ovnsb_db.sock"

Confirm:

ovs-vsctl get Open_vSwitch . external_ids

3. Recreate minimal NB topology (router, switch, VM ports)

If you already have these objects, you can skip recreation; otherwise:

# Clean router↔switch link
ovn-nbctl --if-exists lsp-del sw1-lr0
ovn-nbctl --if-exists lrp-del lr0-sw1

# Router port
ovn-nbctl lrp-add lr0 lr0-sw1 00:00:00:aa:bb:cc 10.255.0.1/24

# Switch-side router port
ovn-nbctl lsp-add sw1 sw1-lr0
ovn-nbctl lsp-set-type sw1-lr0 router
ovn-nbctl lsp-set-addresses sw1-lr0 "00:00:00:aa:bb:cc"
ovn-nbctl lsp-set-options sw1-lr0 router-port=lr0-sw1

# VM ports on sw1 with MAC-only (DHCP-friendly)
ovn-nbctl --if-exists lsp-del vm200
ovn-nbctl --if-exists lsp-del vm201
ovn-nbctl lsp-add sw1 vm200
ovn-nbctl lsp-add sw1 vm201
ovn-nbctl lsp-set-addresses vm200 "BC:24:11:AF:E3:71"
ovn-nbctl lsp-set-addresses vm201 "BC:24:11:EC:0C:23"
ovn-nbctl set Logical_Switch_Port vm200 enabled=true
ovn-nbctl set Logical_Switch_Port vm201 enabled=true
ovn-nbctl clear Logical_Switch_Port vm200 port_security
ovn-nbctl clear Logical_Switch_Port vm201 port_security

# If you have a DHCP options UUID for the /24, attach it later when NB is reachable:
# ovn-nbctl lsp-set-dhcpv4-options vm200 <UUID>
# ovn-nbctl lsp-set-dhcpv4-options vm201 <UUID>

Sanity check:

ovn-nbctl show
# Expect sw1 ports: vm200, vm201, sw1-lr0
# Router lr0 port: lr0-sw1

4. Set interface external_ids for VM taps

Bind OVS interfaces to NB logical ports:

# VM200
ovs-vsctl set Interface tap200i0 external_ids:iface-id=vm200
ovs-vsctl set Interface tap200i0 external_ids:attached-mac="BC:24:11:AF:E3:71"
ovs-vsctl set Interface tap200i0 external_ids:iface-id-ver="1"

# VM201
ovs-vsctl set Interface tap201i0 external_ids:iface-id=vm201
ovs-vsctl set Interface tap201i0 external_ids:attached-mac="BC:24:11:EC:0C:23"
ovs-vsctl set Interface tap201i0 external_ids:iface-id-ver="1"

Verify:

ovs-vsctl get Interface tap200i0 external_ids
ovs-vsctl get Interface tap201i0 external_ids
# Expect iface-id, attached-mac, ovn-installed="true" (after controller sync)

Restart controller to force resync:

/usr/share/ovn/scripts/ovn-ctl start_controller
# If already running, you can:
pkill -f ovn-controller
rm -f /var/run/ovn/ovn-controller.pid
/usr/share/ovn/scripts/ovn-ctl start_controller

5. Validate NB→SB translation and bindings

Controller/SB connectivity:

tail -n 80 /var/log/ovn/ovn-controller.log
# Look for: "ovnsb_db.sock: connected", "br-int.mgmt: connected", "Chassis registered"

Ports should flip up:

ovn-nbctl list Logical_Switch_Port vm200 | grep up
ovn-nbctl list Logical_Switch_Port vm201 | grep up
# Expect up : true

SB shows bindings:

ovn-sbctl show
# Expect under Chassis pve1:
#   Port_Binding vm200
#   Port_Binding vm201

Flows exist on br-int:

ovs-ofctl dump-flows br-int | head -n 30

6. Dataplane test (without DHCP)

Inside VMs:

# VM200
ip addr add 10.255.0.200/24 dev ens18
ip route add default via 10.255.0.1

# VM201
ip addr add 10.255.0.201/24 dev ens18

# Tests
ping -c2 10.255.0.201
ping -c2 10.255.0.1

Optional: observe DHCP later when internet is available:

tcpdump -i br-int port 67 or port 68 -n

7. Keep it working after reboot (service discipline)

Manage OVN with ovn-ctl only. On Proxmox, the canonical OVN start sequence is:

/usr/share/ovn/scripts/ovn-ctl start_ovsdb

/usr/share/ovn/scripts/ovn-ctl start_northd

/usr/share/ovn/scripts/ovn-ctl start_controller

Manage Open vSwitch with systemd:

systemctl enable --now openvswitch-switch

If you want auto-start at boot for OVN:

Create a simple systemd unit that calls ovn-ctl in the right order and After/Requires OVS.

Example unit:

# /etc/systemd/system/ovn-stack.service
[Unit]
Description=Start OVN stack via ovn-ctl
After=network-online.target openvswitch-switch.service
Requires=openvswitch-switch.service

[Service]
Type=oneshot
ExecStart=/usr/share/ovn/scripts/ovn-ctl start_ovsdb
ExecStart=/usr/share/ovn/scripts/ovn-ctl start_northd
ExecStart=/usr/share/ovn/scripts/ovn-ctl start_controller
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

Enable:

systemctl daemon-reload
systemctl enable --now ovn-stack.service

This preserves the proven ovn-ctl paths and avoids conflicts with any packaged OVN systemd units that may not exist or may behave differently on Proxmox.

8. Quick troubleshooting cues

NB socket missing: rerun /usr/share/ovn/scripts/ovn-ctl start_ovsdb; verify /var/run/ovn/ovnnb_db.sock.

Duplicate controllers: pkill -f ovn-controller, remove PID file, start controller via ovn-ctl.

Ports stuck up=false: ensure ovs-vsctl get Interface tapX external_ids contains iface-id=<lsp-name> and attached-mac.

Bindings missing despite up=true: restart northd: /usr/share/ovn/scripts/ovn-ctl start_northd (or pkill ovn-northd then start; avoid systemctl if not used elsewhere).

Flows missing: confirm br-int exists and controller log shows br-int.mgmt: connected.

If you want, I can tailor the ovn-stack.service to include your strict region labeling and NetBox-ready annotations so it’s recruiter-ready and audit-friendly.