#!/bin/bash

# Interface to clean up
BRIDGE=vmbr0

# Remove tc rules
tc qdisc del dev $BRIDGE ingress 2>/dev/null
tc qdisc del dev $BRIDGE root 2>/dev/null
