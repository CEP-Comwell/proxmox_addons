# proxmox_addons
Additional features for configuring Proxmox VE host templates

---

### 📄 **1. `tc-mirror.sh`**
This script sets up ingress and egress mirroring from `vmbr0` to `tapmon0`.

```bash
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
```

---

### 📄 **2. `tc-mirror-cleanup.sh`**
This script removes the mirroring rules from `vmbr0`.

```bash
#!/bin/bash

# Interface to clean up
BRIDGE=vmbr0

# Remove tc rules
tc qdisc del dev $BRIDGE ingress 2>/dev/null
tc qdisc del dev $BRIDGE root 2>/dev/null
```

---

### 📄 **3. `tc-mirror.service`**
This is the systemd service file to make the mirroring persistent.

```ini
[Unit]
Description=Mirror vmbr0 traffic to tapmon0
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/tc-mirror.sh
ExecStop=/usr/local/bin/tc-mirror-cleanup.sh
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
```

---

### ✅ Installation Tips

1. Save the two scripts to `/usr/local/bin/` and make them executable:

```bash
sudo chmod +x /usr/local/bin/tc-mirror.sh
sudo chmod +x /usr/local/bin/tc-mirror-cleanup.sh
```

2. Save the service file to `/etc/systemd/system/tc-mirror.service`.

3. Reload systemd and enable the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now tc-mirror.service
```
