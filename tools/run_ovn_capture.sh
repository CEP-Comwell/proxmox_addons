#!/bin/bash
set -euo pipefail
TS=$(date +%s)
DIR=/tmp/ovn_capture_$TS
mkdir -p "$DIR"

# Start 70s captures (allow short prep time); stdout/stderr logs written next to pcaps
timeout 70s tcpdump -i br-int  -s 0 -w "$DIR"/capture_br-int.pcap 2> "$DIR"/tcpdump-br-int.log &
timeout 70s tcpdump -i br-ext  -s 0 -w "$DIR"/capture_br-ext.pcap 2> "$DIR"/tcpdump-br-ext.log &

# Capture VM tap interface if present
if ip link show tap200i0 > /dev/null 2>&1; then
  timeout 70s tcpdump -i tap200i0 -s 0 -w "$DIR"/capture_tap200i0.pcap 2> "$DIR"/tcpdump-tap200i0.log &
else
  echo "tap200i0 not present; skipping tap capture" > "$DIR"/tap-capture.info
fi

# Capture ovn-controller journal during the window
timeout 70s journalctl -u ovn-controller -f > "$DIR"/ovn-controller-live.log 2>&1 &

echo "Captures started for ~60s; directory: $DIR"

# Wait for background timeouts to finish
wait

# Archive results
tar -C /tmp -czf /tmp/ovn_capture_$TS.tgz "$(basename "$DIR")"

echo "Created /tmp/ovn_capture_$TS.tgz"
ls -lh /tmp/ovn_capture_$TS.tgz
