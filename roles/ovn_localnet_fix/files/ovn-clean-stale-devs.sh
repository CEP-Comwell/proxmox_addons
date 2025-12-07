#!/bin/bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "No device names supplied; nothing to do."
  exit 0
fi

for dev in "$@"; do
  if ip link show "$dev" >/dev/null 2>&1; then
    # If OVS manages it, skip deletion
    if ovs-vsctl --bare list Interface "$dev" >/dev/null 2>&1; then
      echo "Device $dev is managed by OVS; skipping"
      continue
    fi
    echo "Deleting stale device $dev"
    ip link delete "$dev" || echo "failed to delete $dev (continuing)"
  else
    echo "Device $dev not present"
  fi
done
