#!/bin/bash

# Interface to monitor
BRIDGE=vmbr0
TAP=tapmon0

# Clean up existing rules (optional)
tc qdisc del dev $BRIDGE ingress 2>/dev/null
tc qdisc del dev $BRIDGE root 2>/dev/null

# Add ingress mirroring
tc qdisc add dev $BRIDGE ingress
tc filter add dev $BRIDGE parent ffff: \
    protocol all u32 match u32 0 0 \
    action mirred egress mirror dev $TAP

# Add egress mirroring
tc qdisc add dev $BRIDGE handle 1: root prio
tc filter add dev $BRIDGE parent 1: \
    protocol all u32 match u32 0 0 \
    action mirred egress mirror dev $TAP
