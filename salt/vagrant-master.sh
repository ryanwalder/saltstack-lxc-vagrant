#!/usr/bin/env bash
# Quick and dirty salt bootstrap script for vagrant

# Add saltstack repository to apt
echo deb http://ppa.launchpad.net/saltstack/salt/ubuntu `lsb_release -sc` main > /etc/apt/sources.list.d/saltstack.list && \
wget -q -O- "http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x4759FA960E27C0A6" | apt-key add - && \
apt-get update

# Move master/minion configs into place
if ! mv /tmp/master /etc/salt/master ;then exit 1; fi
if ! mv /tmp/minion /etc/salt/minion ;then exit 1; fi
if ! chown root.root /etc/salt/* ;then exit 1; fi

# Install Salt-Master
apt-get install -y -o Dpkg::Options::="--force-confold" salt-master
