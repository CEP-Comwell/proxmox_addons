
# Proxmox SDN Migration: OVS → OVN Package Review

| Group                | Package Name           | Installed Version       | Required for OVN? | Comments                                                                 |
|----------------------|------------------------|-------------------------|-------------------|--------------------------------------------------------------------------|
| **Core OVS**         | openvswitch-switch    | 3.5.0-1+b1             | ❌                | Main OVS daemon; remove if fully switching to OVN.                      |
|                      | openvswitch-common    | 3.5.0-1+b1             | ❌                | Common OVS utilities; remove if OVN replaces OVS completely.            |
|                      | python3-openvswitch   | 3.5.0-1+b1             | ❌                | Python bindings for OVSDB; not needed for OVN unless legacy scripts.    |
| **OVS Acceleration** | libxdp1              | 1.5.4-1                | ❌                | XDP acceleration for OVS; OVN does not use XDP directly.                |
| **Python Utilities** | python3-rich          | 13.9.4-1               | ✅ (UI only)      | CLI formatting; used by Proxmox UI/automation, not OVN datapath.        |
|                      | python3-click         | 8.2.0+0.really.8.1.8-1 | ✅ (UI only)      | CLI toolkit; safe to keep if Proxmox SDN UI remains.                    |
|                      | python3-sortedcontainers| 2.4.0-2              | ✅ (UI only)      | Data structures; used by SDN scripts/UI.                                |
|                      | python3-netaddr       | 1.3.0-1                | ✅ (UI only)      | IP/MAC manipulation; useful for SDN automation.                         |
|                      | python3-netifaces     | 0.11.0-2+b6            | ✅ (UI only)      | Network interface queries; used by SDN scripts.                         |
|                      | python3-mdurl         | 0.1.2-1                | ✅ (UI only)      | Markdown parsing; UI-related only.                                      |
|                      | python3-markdown-it   | 3.0.0-3                | ✅ (UI only)      | Markdown rendering; UI-related only.                                    |
|                      | python3-linkify-it    | 2.0.3-1                | ✅ (UI only)      | Link detection; UI-related only.                                        |
|                      | python3-uc-micro      | 1.0.3-1                | ✅ (UI only)      | Unicode utilities; UI-related only.                                     |
| **Misc Data**        | ieee-data             | 20240722               | ✅ (optional)     | MAC vendor database; useful for UI or scripts, not core OVN.            |

---

## ✅ Migration Notes
- **Remove**: `openvswitch-switch`, `openvswitch-common`, `python3-openvswitch`, `libxdp1` if OVN fully replaces OVS.
- **Keep**: Python utilities if Proxmox SDN UI or automation remains active.
- **OVN Packages to Install**: `ovn-central`, `ovn-host`, and dependencies.
- **Check**: Any custom scripts calling OVSDB or XDP before removal.
