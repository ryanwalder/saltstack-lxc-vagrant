# saltstack-lxc-vagrant

Vagrantfile for spinning up a local Salt Master and minions, all defined in YAML because YAML is nice to read and anyone using salt should be familiar with it!

## Requirements

This assumes Ubuntu a 16.04 host, but should work on any modern linux distro (package names are likely vary)

### A Note on Boxes

For now the default box is the `fgrehm/trusty64-lxc` box which is reasonably out of date due to the maintainer of the Vagrant lxc base boxes stepping down so this box is no longer updated or uploaded to Atlas, you can however really easily make your own boxes from the forked and maintained [repo](https://github.com/obnoxxx/vagrant-lxc-base-boxes) which you can use either locally or upload to a server and use the url.

### Packages


0. Vagrant 1.5+ (tested with 1.7.2)
0. lxc 0.7.5+
0. tar 1.27 (the lxc-template script uses the --xattrs option)
0. `redir` (if you are planning to use port forwarding)
0. `brctl` (if you are planning to use private networks, on Ubuntu this means apt-get install bridge-utils)
0. [kernel !=3.5.0-17.28](https://github.com/fgrehm/vagrant-lxc/wiki/Troubleshooting#im-unable-to-restart-containers)

### Vagrant plugins

1. [vagrant-lxc](https://github.com/fgrehm/vagrant-lxc)
2. [salty-vagrant-grains](https://github.com/ahmadsherif/salty-vagrant-grains) (optional)

If installed the vagrant-salty-grains plugin will be used for creating grains on the minions and devmaster.

## Quickstart

0. Clone the repo
    * `git clone https://github.com/ryanwalder/saltstack-lxc-vagrant.git`
0. Copy the `vagrant.example.yaml` to `vagrant.yaml`
    * `cd saltstack-lxc-vagrant && cp vagrant.example.yaml vagrant.yaml`
0. Check your available boxes
    * `vagrant status`
0. Spin up the devmaster
    * `vagrant up saltmaster`
0. Spin up the minions as desired
    * `vagrant up box-01`

> Note: This Vagrantfile does not run a highstate by default (configurable below) as I find it can slow things down when developing states. Once you're all up and running you can ssh into it and run a highstate manually with `vagrant ssh minion-box` then `sudo salt-call state.highstate`


## YAML file

All settings and minions are defined in the `vagrant.yaml` file, an example is provided: `vagrant.example.yaml`.

### Global Settings

All global settings are stored under the `settings` key, some can be overidden on a per machine basis (detailed below).

| Key | Use | Default Value |
| --- | --- | ------------- |
| `salt_version` | Set version of salt to use/install | stable |
| `domain` | Appended to the end of minion names | |
| `default_box` | Default box to use for minions | fgrehm/trusty64-lxc |
| `default_box_url` | Default box URL | |
| `master_box` | Master box to use | `default_box` |
| `master_box_url` | Master box URL | |
| `network` | Network to use for vagrant (/24), without last octect | 10.0.3 |
| `bridge` | Network bridge device to use | 'lxcbr0' |
| `folders` | Dict of folders and destinations to be mounted on the master | |

```YAML
settings:
  default_box: fgrehm/trusty64-lxc
  network: 10.66.6
  master_grains:
    foo: bar
    baz:
      one: 1
    qux:
      - blah
```

### Salt Settings

Both the Master and Minion configs are automatically generated if they don't exist or when you update the `vagrant.yaml`. You can configure the salt install options and the master/minion config settings directly in the YAML.

> NOTE: Updating either the master or minion config will require reprovisioning all machines as these files are injected during machine creation

#### Master Config

This is a block of YAML that will be translated to the [master config](https://docs.saltstack.com/en/latest/ref/configuration/master.html) on the `saltmaster` machine.

```YAML
settings:
  salt:
    master:
      config:
        foo: bar
        some_options:
          - one
          - two
          - three
```

#### Master Grains

If you're using the vagrant-salty-grains plugin you can set master grains via the YAML file (probably not needed as the `devmaster` doesn't really do much other than mount local files and run the master process)

```YAML
settings:
  salt:
    master:
      grains:
        one: two
        alist:
          - foo
          - bar
```

#### Minion Config

Exactly the same as the master config just using the minion YAML key instead.

```YAML
settings:
  salt:
    minion:
      config:
        foo: bar
        some_options:
          - one
          - two
          - three
```

## Default grains

If you're using the vagrant-salty-grains plugin you can set default grains which will be applied to all minions, these will be merged with any grains specified on a per minion basis (detailed below)

```YAML
settings:
  salt:
    minions:
      default_grains:
        foo: bar
        grains_list:
          - baz
          - qux
```

## Minions

Minions are defined under the `minions` key with a number of settings available per minion

| Key | Use | Default Value |
| --- | --- | ------------- |
| `name` | Name of the minion | none (required) |
| `cpu` | Number of CPUs assigned to the container | 1 |
| `ram` | Amount of RAM assigned to the container | 512M |
| `box` | Box to use for the minion | `default_box` |
| `box_url` | Box URL for the above box | none |
| `folders` | Folders to share with the minion | none |
| `grains` | Grains to set on the minion | {} |
| `highstate` | Run highstate on minion during provisioning | flase |

### Minimum YAML Needed for a Minion

```YAML
minions:
  - name: minion-box
```

### Shared Folders
If you need to share folders with the minion you can add them in like so:

```yaml
minions:
  - name: minion-box
    folders:
      - from: ~/source/folder
        to: /destination/folder
```

You can repeat this as many times as needed:

```yaml
minions:
  - name:
    folders:
      - from: ~/source/folder1
        to: /destination/folder1
      - from: ~/source/folder2
        to: /destination/folder2
      - from: ~/source/folder3
        to: /destination/folder3
```

### Per Minion Grains

```yaml
minions:
  - name: minion-box
    grains:
      foo: bar
      baz:
        one: 1
      qux:
        - blah
```

### Example minion.yaml

```yaml
minions:
  - name: minion-01
  - name: minion-02
    box: fakebox
    box_url: http://example.com/fakebox.box
    grains:
      i_like_turtles: true
  - name: minion-03
    ram: 1024M
    cpu: 4
    highstate: true
    folders:
      - from: ~/boom
        to: /shanka

```

# Notes

It's always best to fire up the `devmaster` before the minions or you can get everything in a bit of a race condition where the minions come up before the master which leads to a broken setup where the minions are up before the master where you need to manually restart the salt-minion on each minion box to get them talking to the master properly, and that's no fun.
