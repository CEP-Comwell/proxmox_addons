Step-by-step setup for an independent OVN node

This procedure gets a Proxmox host to run its own OVN NB/SB databases, northd, and ovn-controller on TCP, with br-int flows populated after boot.

Prerequisites and reset

Assumptions:

Proxmox host with Open vSwitch installed.

You want standalone operation (no central OVN).

You prefer TCP sockets for NB/SB: 127.0.0.1:6641/6642.

Stop and mask distro units:

systemctl stop ovn-controller ovn-northd ovn-ovsdb-server-nb ovn-ovsdb-server-sb ovn-central ovn-host || true
systemctl mask ovn-controller ovn-northd ovn-ovsdb-server-nb ovn-ovsdb-server-sb ovn-central ovn-host

Clear stale processes and sockets:

pkill -f ovn-northd || true
pkill -f ovn-controller || true
pkill -f "ovsdb-server.*ovnnb_db.db" || true
pkill -f "ovsdb-server.*ovnsb_db.db" || true
rm -f /var/run/ovn/ovnnb_db.sock /var/run/ovn/ovnsb_db.sock \
      /var/run/ovn/ovn-controller.pid /var/run/ovn/ovn-controller.*.sock

Ensure br-int exists:

ovs-vsctl br-exists br-int || ovs-vsctl add-br br-int

Configure external_ids (canonical chassis identity)

Set required external_ids:

# Clear prior external_ids (optional if you want a clean slate)
ovs-vsctl clear Open_vSwitch . external_ids

# Chassis ID (short, stable)
ovs-vsctl set Open_vSwitch . external_ids:system-id="pve1"

# NB/SB over TCP localhost
ovs-vsctl set Open_vSwitch . external_ids:ovn-nb="tcp:127.0.0.1:6641"
ovs-vsctl set Open_vSwitch . external_ids:ovn-sb="tcp:127.0.0.1:6642"
ovs-vsctl set Open_vSwitch . external_ids:ovn-remote="tcp:127.0.0.1:6642"

# Integration bridge
ovs-vsctl set Open_vSwitch . external_ids:ovn-bridge="br-int"

# Encapsulation (per-host IP)
ovs-vsctl set Open_vSwitch . external_ids:ovn-encap-type="geneve"
ovs-vsctl set Open_vSwitch . external_ids:ovn-encap-ip="172.16.10.20"

Verify:

ovs-vsctl get Open_vSwitch . external_ids

Create ovn-local systemd unit (TCP NB/SB, northd, controller)

Unit file with TCP listeners enabled:

# /etc/systemd/system/ovn-local.service
[Unit]
Description=OVN full stack (NB/SB/northd/controller) for standalone node
After=network.target

[Service]
ExecStart=/usr/share/ovn/scripts/ovn-ctl \
  --db-nb-addr=127.0.0.1 --db-nb-port=6641 --db-nb-create-insecure-remote=yes \
  --db-sb-addr=127.0.0.1 --db-sb-port=6642 --db-sb-create-insecure-remote=yes \
  start_northd
ExecStartPost=/usr/share/ovn/scripts/ovn-ctl start_controller
ExecStop=/usr/share/ovn/scripts/ovn-ctl stop_northd
ExecStopPost=/usr/share/ovn/scripts/ovn-ctl stop_controller
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target

Enable and start:

systemctl daemon-reload
systemctl enable ovn-local
systemctl start ovn-local

If controller fails to start (stale pid/socket):

rm -f /var/run/ovn/ovn-controller.pid /var/run/ovn/ovn-controller.*.sock
systemctl restart ovn-local

Post-boot verification

Check NB/SB TCP listeners:

ss -ltnp | grep -E '6641|6642'
# Expect:
# LISTEN 127.0.0.1:6641 (ovsdb-server)
# LISTEN 127.0.0.1:6642 (ovsdb-server)

Confirm chassis registration:

ovn-sbctl show | grep Chassis
# Expect: Chassis pve1

Confirm flows in br-int:

ovs-ofctl dump-flows br-int | head -n 30
# Expect multiple tables populated (not just header)

Optional one-shot manual start (for troubleshooting)

If you need to start without systemd to validate options:

/usr/share/ovn/scripts/ovn-ctl \
  --db-nb-addr=127.0.0.1 --db-nb-port=6641 --db-nb-create-insecure-remote=yes \
  --db-sb-addr=127.0.0.1 --db-sb-port=6642 --db-sb-create-insecure-remote=yes \
  start_northd
/usr/share/ovn/scripts/ovn-ctl start_controller

Then verify ports, chassis, and flows as above. If this works, your unit file will, too.

What you should see at the end

TCP listeners: NB on 127.0.0.1:6641, SB on 127.0.0.1:6642.

Chassis: pve1 present in ovn-sbctl show.

Flows: Non-empty pipeline in br-int.

If you want, I can tailor this with pve2/pve3 variations (system-id and ovn-encap-ip) and a short health-check script you can run after every reboot.