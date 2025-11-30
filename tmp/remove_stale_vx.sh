#!/bin/bash
set -e

# Find and destroy Interface UUIDs for vx* with ofport <= 0
ovs-vsctl --bare --columns=_uuid,name,ofport list Interface | awk 'BEGIN{RS="";FS="\n"} {u=$1; n=$2; o=$3; gsub(/_uuid[[:space:]]*:[[:space:]]*/,"",u); gsub(/name[[:space:]]*:[[:space:]]*/,"",n); gsub(/ofport[[:space:]]*:[[:space:]]*/,"",o); if(n ~ /^vx/ && (o+0) <= 0) print u}' | while read -r uuid; do
  echo "destroying $uuid"
  ovs-vsctl --if-exists destroy Interface $uuid || true
done

echo '--- Interfaces after destroy ---'
ovs-vsctl --columns=_uuid,name,type,ofport,options list Interface || true

echo; echo '--- datapath ---'
ovs-dpctl show || true

echo; echo '--- ovs-vswitchd logs (relevant) ---'
journalctl -u ovs-vswitchd -n 120 --no-pager | egrep -i 'could not add|attempting to add|unknown vxlan argument|File exists' || true
