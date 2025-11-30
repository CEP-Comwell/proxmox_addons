#!/usr/bin/env python3
import subprocess,shlex,re
try:
    o = subprocess.check_output(shlex.split('ip -o link show')).decode()
except Exception as e:
    print('ip link error',e)
    raise
names = re.findall(r"\d+:\s*([^:@]+):", o)
for n in names:
    if n.startswith('vx'):
        print('DEL',n)
        subprocess.call(shlex.split(f'ip link del {n}'))
print('done')
