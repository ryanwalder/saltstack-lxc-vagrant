#!/usr/bin/env bash
# Quick and dirty salt bootstrap script for vagrant

# Add saltstack ubuntu repo
echo deb http://ppa.launchpad.net/saltstack/salt/ubuntu `lsb_release -sc` main > /etc/apt/sources.list.d/saltstack.list && \
wget -q -O- "http://keyserver.ubuntu.com:11371/pks/lookup?op=get&search=0x4759FA960E27C0A6" | apt-key add - && \
apt-get clean && \
apt-get update

# Move minion configs into place
if ! mv /tmp/minion /etc/salt/minion ;then exit 1; fi
if ! chown root.root /etc/salt/* ;then exit 1; fi

# Install salt minion
apt-get install -y -o Dpkg::Options::="--force-confold" salt-minion

# Stop the minion to prevent initial highstate (can slow down dev imho)
service salt-minion stop
