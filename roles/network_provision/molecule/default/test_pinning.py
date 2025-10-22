# Molecule test for .link and .rules generation in network_provision role

import os
import pytest
import testinfra

@pytest.mark.parametrize("file_path", [
    "/etc/systemd/network/10-pve-xg1.link",
    "/etc/udev/rules.d/70-pve-net-eth1.rules",
])
def test_pinning_files_exist(host, file_path):
    f = host.file(file_path)
    assert f.exists
    assert f.user == "root"
    assert f.group == "root"
    assert f.mode & 0o644 == 0o644

def test_udev_reload(host):
    # Check that udev rules have been reloaded (simulate by checking process)
    udevadm = host.run("pgrep -f udevadm")
    assert udevadm.rc == 0
