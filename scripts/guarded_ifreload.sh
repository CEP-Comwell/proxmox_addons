#!/usr/bin/env bash
set -euo pipefail

# Guarded ifreload helper
# - Validates /etc/network/interfaces with ifquery
# - Makes a timestamped backup before attempting reload
# - Runs ifreload -a and exits with its exit code
# - On failure restores the backup and exits non-zero

BACKUP="/etc/network/interfaces.bak.$(date -Iseconds)"

echo "[guarded_ifreload] Checking ifquery parseability..."
if ! ifquery --list >/dev/null 2>&1; then
  echo "[guarded_ifreload] ifquery reported errors — aborting. Do not attempt reload."
  ifquery --list || true
  exit 2
fi

echo "[guarded_ifreload] Backing up /etc/network/interfaces -> ${BACKUP}"
cp -a /etc/network/interfaces "${BACKUP}"

# Ensure critical manual stanzas are present. If they're missing, try to restore
# from a previous backup (if any) and abort the reload to avoid losing SSH.
REQUIRED=("iface bonding_masters inet manual" "iface dummy_fab-core inet manual")
MISSING=()
for r in "${REQUIRED[@]}"; do
  if ! grep -Fq -- "$r" /etc/network/interfaces; then
    MISSING+=("$r")
  fi
done
if [ ${#MISSING[@]} -ne 0 ]; then
  echo "[guarded_ifreload] Required stanza(s) missing from /etc/network/interfaces:" >&2
  for m in "${MISSING[@]}"; do echo "  - $m" >&2; done
  # Try to find the most recent pre-existing backup (excluding the one we just created)
  LATEST_BACKUP=$(ls -1t /etc/network/interfaces.bak.* 2>/dev/null | grep -v "${BACKUP}" | head -n1 || true)
  if [ -n "${LATEST_BACKUP}" ]; then
    echo "[guarded_ifreload] Found previous backup ${LATEST_BACKUP}; restoring it and aborting reload" >&2
    cp -a "${LATEST_BACKUP}" /etc/network/interfaces
    echo "[guarded_ifreload] Restored /etc/network/interfaces from ${LATEST_BACKUP}" >&2
  else
    echo "[guarded_ifreload] No previous backup found to restore; leaving current file intact and aborting reload" >&2
  fi
  exit 3
fi

echo "[guarded_ifreload] Running ifreload -a"
ifreload -a
RC=$?

if [ ${RC} -ne 0 ]; then
  echo "[guarded_ifreload] ifreload failed with rc=${RC}, restoring backup ${BACKUP}"
  cp -a "${BACKUP}" /etc/network/interfaces
  echo "[guarded_ifreload] Restored /etc/network/interfaces from backup"
  exit ${RC}
fi

echo "[guarded_ifreload] ifreload succeeded (rc=0)"
exit 0
