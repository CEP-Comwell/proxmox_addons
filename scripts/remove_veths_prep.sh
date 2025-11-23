#!/bin/bash
set -x

# Backup interfaces
ts=$(date +%s)
cp /etc/network/interfaces /etc/network/interfaces.bak.$ts || true
echo "backup saved to /etc/network/interfaces.bak.$ts"

# Show OVS ports
echo "OVS ports vmbr1:"
ovs-vsctl list-ports vmbr1 || true
echo "OVS ports vmbr99:"
ovs-vsctl list-ports vmbr99 || true

# Remove candidate OVS ports that look like veths
for br in vmbr1 vmbr99; do
  for p in $(ovs-vsctl list-ports $br || true); do
    case "$p" in
      vetho*|veth*|vethl*)
        echo "Removing OVS port $p from $br"
        ovs-vsctl --if-exists del-port $br $p || true
      ;;
    esac
  done
done

# Stop glue service to avoid recreation
echo "Stopping edgesec-glue.service"
systemctl stop edgesec-glue.service || true
systemctl status edgesec-glue.service --no-pager -l || true

# Find and delete veth-like interfaces
echo "Finding veth-like interfaces"
for ifn in $(ip -o link show | cut -d: -f2 | sed 's/^ *//' | egrep -o '^(vetho[0-9]+|vethl[0-9]+|veth[0-9]+)' | sort -u || true); do
  [ -z "$ifn" ] && continue
  echo "Processing interface: $ifn"
  ip -d link show $ifn || true
  echo "Bringing $ifn down"
  ip link set $ifn down || true
  echo "Deleting $ifn"
  ip link del $ifn || true
done

# Bring vmbr2 down and delete runtime device
echo "vmbr2 state before:"
ip -d link show vmbr2 || true

echo "Bringing vmbr2 down"
ip link set vmbr2 down || true

echo "Attempting to delete vmbr2"
ip link del vmbr2 2>/dev/null || true

# Final verification
echo "--- verification ---"
ovs-vsctl list-br || true
ovs-vsctl show || true
ip -d link show vmbr2 || true
ip -d link show type veth || true
systemctl status edgesec-glue.service --no-pager -l || true
ifquery --list || true
tail -n 80 /etc/network/interfaces || true
