#!/usr/bin/env bash
set -euo pipefail
OUT_PREFIX=/tmp/ovn_validator
PRE=${OUT_PREFIX}_pre.txt
POST=${OUT_PREFIX}_post.txt
PCAP=${OUT_PREFIX}_br-ext.pcap
LOG=${OUT_PREFIX}_run.log
HOST_IF=br-ext
CAND=uplink-v11

echo "Validator run: $(date)" | tee "$LOG"

echo "== Pre-state: ovs-vsctl show ==" | tee -a "$LOG" "$PRE"
ovs-vsctl show 2>&1 | tee -a "$LOG" "$PRE"

echo "\n== Pre-state: ovs-vsctl list Interface (condensed) ==" | tee -a "$LOG" "$PRE"
ovs-vsctl list Interface | sed -n '1,120p' | tee -a "$LOG" "$PRE"

echo "\n== ip link show $CAND ==" | tee -a "$LOG" "$PRE" || true
ip -d link show "$CAND" 2>&1 | tee -a "$LOG" "$PRE" || true

echo "\n== ovs-vsctl --format=json list Interface $CAND (if exists) ==" | tee -a "$LOG" "$PRE"
ovs-vsctl --if-exists list Interface "$CAND" 2>&1 | tee -a "$LOG" "$PRE"

echo "\n== /proc/net/nf_conntrack exists? ==" | tee -a "$LOG" "$PRE"
if [ -e /proc/net/nf_conntrack ]; then echo yes | tee -a "$LOG" "$PRE"; else echo no-proc | tee -a "$LOG" "$PRE"; fi

echo "\n== conntrack count (netlink) ==" | tee -a "$LOG" "$PRE"
if command -v conntrack >/dev/null 2>&1; then conntrack -L 2>/dev/null | wc -l | tee -a "$LOG" "$PRE" || true; else echo conntrack-missing | tee -a "$LOG" "$PRE"; fi

echo "\n== Check if $CAND is a dummy and not OVS-managed ==" | tee -a "$LOG" "$PRE"
IS_DUMMY=0
if ip -d link show "$CAND" 2>/dev/null | grep -q dummy; then IS_DUMMY=1; fi
IS_OVS_MANAGED=0
if ovs-vsctl --if-exists get Interface "$CAND" name 2>/dev/null | grep -q .; then IS_OVS_MANAGED=1; fi

echo "IS_DUMMY=$IS_DUMMY IS_OVS_MANAGED=$IS_OVS_MANAGED" | tee -a "$LOG" "$PRE"

# Only delete if dummy and NOT OVS-managed
if [ "$IS_DUMMY" -eq 1 ] && [ "$IS_OVS_MANAGED" -eq 0 ]; then
  echo "Removing kernel dummy $CAND" | tee -a "$LOG"
  ip link delete "$CAND" || true
  REMOVED=1
else
  echo "Not removing $CAND (either not dummy or managed by OVS)" | tee -a "$LOG"
  REMOVED=0
fi

# Restart OVN local unit to allow it to create native localnet devices
echo "\n== Restarting ovn-local.service ==" | tee -a "$LOG"
systemctl daemon-reload || true
systemctl restart ovn-local.service || true
sleep 5

echo "\n== Post-state: ovs-vsctl show ==" | tee -a "$LOG" "$POST"
ovs-vsctl show 2>&1 | tee -a "$LOG" "$POST"

echo "\n== Post-state: list Interface $CAND ==" | tee -a "$LOG" "$POST"
ovs-vsctl --if-exists list Interface "$CAND" 2>&1 | tee -a "$LOG" "$POST"

# Capture short pcap on host bridge to observe egress; run in background and stop after 15s
if ip link show "$HOST_IF" >/dev/null 2>&1; then
  echo "Starting 15s pcap on $HOST_IF -> $PCAP" | tee -a "$LOG"
  timeout 15 tcpdump -i "$HOST_IF" -w "$PCAP" -s 0 2>/dev/null || true
  echo "Pcap saved to $PCAP" | tee -a "$LOG"
else
  echo "Host interface $HOST_IF not present; skipping pcap" | tee -a "$LOG"
fi

# Summarize
echo "\n== Summary ==" | tee -a "$LOG"
echo "Removed dummy: $REMOVED" | tee -a "$LOG"
echo "Pre: $PRE" | tee -a "$LOG"
echo "Post: $POST" | tee -a "$LOG"
echo "Run log: $LOG" | tee -a "$LOG"

echo "Validator finished: $(date)" | tee -a "$LOG"

# Exit
exit 0
