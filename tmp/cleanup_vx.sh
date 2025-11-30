#!/bin/bash
set -eu
for name in $(ovs-vsctl --bare --no-heading list Interface name | grep -E '^vx' || true); do
  type=$(ovs-vsctl --bare --no-heading --columns=type list Interface "$name" 2>/dev/null || echo "")
  opts=$(ovs-vsctl --bare --no-heading --columns=options list Interface "$name" 2>/dev/null || echo "")
  echo "CHECK:$name|'$type'|'$opts'"
  if ! echo "$type" | grep -q vxlan || ! echo "$opts" | grep -q 'key="flow"'; then
    br=$(ovs-vsctl port-to-br "$name" 2>/dev/null || echo "")
    echo "BACKUP:/tmp/${name}.json"
    ovs-vsctl --format=json list Interface "$name" > /tmp/${name}.json || true
    echo "DELPORT:$br $name"
    ovs-vsctl --if-exists del-port "$br" "$name" || true
  fi
done
echo done
