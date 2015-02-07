# saltstack-lxc-vagrant
Vagrantfile for setting up a SaltStack test/dev environment.

## Requirements

This assumes Ubuntu 14.04 host, package name likely vary in other distros.

Packages (apt-get install):

1. vagrant
2. lxc
3. cgroups-lite
4. redir

Vagrant plugins (vagrant plugin install):

1. vagrant-lxc plugin
2. salty-vagrant-grains

## Setup

Edit the config.yaml file with the paths to your salt states and salt pillars, these are shared with the salt master so you can develop states from the comfort of your own environment, as soon as you save your files you can use them immediately either from the master or minion.

From the master:

````sudo salt 'minion1' state.highstate````

From the minion:

````sudo salt-call state.highstate````

## Time to play!

First we need to fire up the Salt Master

````vagrant up saltmaster````

Once this has booted and configured itself you can now fire up your minions(s)

````vagrant up minion1````

You can have up to 10 minions at a time so you can test/develop clusters or multiple connected systems at once.

## Notes

I do not suggest firing up both master and minions at the same time as this can lead to a broken setup where the minions are up before the master which means you need to manually restart the salt-minion on each minion box to get them taliking to the master properly, and that's no fun.
