#!/usr/bin/env python3
"""
merge_interfaces.py

Merge a controller-rendered OVS managed block into an existing /etc/network/interfaces
content. The script removes any existing managed BEGIN/END blocks and removes any
blank-line separated paragraphs that contain 'ovs_type OVSBridge' or 'ovs_type OVSPort'
to avoid orphaned stanzas. Then it inserts the new managed block before the
line that starts with 'source /etc/network/interfaces.d/' or at EOF. It normalizes
to have exactly one blank line above the '# BEGIN OVS BRIDGES' marker.

Usage:
    merge_interfaces.py <existing_file> <new_block_file> <out_file>

The script writes merged output to out_file and exits 0 on success.
"""
import sys
import re


def read_text(path):
    with open(path, 'r', encoding='utf-8') as f:
        return f.read()


def write_text(path, text):
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)


def remove_managed_blocks_and_orphans(existing):
    # Remove explicit BEGIN/END blocks (non-greedy)
    existing = re.sub(r"(?s)# BEGIN OVS BRIDGES\n.*?# END OVS BRIDGES\n?", "\n", existing)

    # Split into paragraphs separated by blank lines
    paras = re.split(r"\n\s*\n", existing)
    kept = []
    for p in paras:
        if re.search(r"ovs_type\s+OVSBridge", p) or re.search(r"ovs_type\s+OVSPort", p):
            # drop this paragraph (it looks like an OVS stanza)
            continue
        kept.append(p.rstrip())

    # Rejoin with exactly one blank line
    out = "\n\n".join([k for k in kept if k != ''])
    if out and not out.endswith("\n"):
        out += "\n"
    return out


def insert_managed_block(existing, block):
    # Ensure block has markers
    block = block.rstrip() + "\n"
    if not block.startswith('# BEGIN OVS BRIDGES'):
        block = '# BEGIN OVS BRIDGES\n\n' + block
    if not block.rstrip().endswith('# END OVS BRIDGES'):
        block = block.rstrip() + "\n# END OVS BRIDGES\n"

    # Normalize single blank line before BEGIN
    block = '\n' + block if not block.startswith('\n') else block

    insert_before_re = re.compile(r'^source\s+/etc/network/interfaces.d/.*$', re.MULTILINE)
    m = insert_before_re.search(existing)
    if m:
        idx = m.start()
        prefix = existing[:idx].rstrip() + '\n\n'
        suffix = existing[idx:]
        return prefix + block + '\n' + suffix.lstrip()
    else:
        # Append to EOF with a blank line separator
        existing = existing.rstrip() + '\n\n'
        return existing + block


def merge(existing_text, new_block_text):
    base = remove_managed_blocks_and_orphans(existing_text)
    merged = insert_managed_block(base, new_block_text)
    # Collapse multiple trailing newlines to single
    merged = re.sub(r"\n{3,}", "\n\n", merged)
    return merged


def main():
    if len(sys.argv) != 4:
        print('Usage: merge_interfaces.py <existing_file> <new_block_file> <out_file>')
        return 2
    existing_file, new_block_file, out_file = sys.argv[1:4]
    existing = read_text(existing_file)
    new_block = read_text(new_block_file)
    merged = merge(existing, new_block)
    write_text(out_file, merged)
    return 0


if __name__ == '__main__':
    sys.exit(main())
