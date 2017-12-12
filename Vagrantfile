# -*- mode: ruby -*-
# vi: set ft=ruby :

# Minimum Vagrant version and Vagrant API version needed, include YAML module
Vagrant.require_version '>= 1.8.0'
VAGRANTFILE_API_VERSION = '2'
require 'yaml'

# Check we have vagrant plugins and lxc installed
unless Vagrant.has_plugin?('vagrant-lxc')
  puts 'vagrant-lxc plugin is not installed!'
  exit 1
end

unless system('which lxc-create >/dev/null')
  puts 'lxc not installed!'
  exit 1
end

# Explicitly set lxc as the provider
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'lxc'

# Read YAML file to get settings and minions
config          = YAML.load_file('vagrant.yaml')
settings        = config['settings']          || {}
salt            = settings['salt']            || {}
master          = salt['master']              || {}
minion          = salt['minion']              || {}
master_config   = master['config']            || {}
minion_config   = minion['config']            || {}
minions         = config['minions']           || []

# Set options from config, use defaults if they don't exist
salt_version    = settings['salt_version']    || 'stable'
install_args    = settings['install_args']    || ''
domain          = ".#{settings['domain']}"    || ''
default_box     = settings['default_box']     || 'fgrehm/trusty64-lxc'
network         = settings['network']         || '10.0.3'
bridge          = settings['bridge']          || 'lxcbr0'
master_box      = master['box']               || default_box
master_box_url  = master['box_url']           || false
master_grains   = master['grains']            || {}
master_folders  = master['folders']           || [{"from" => "salt/salt", "to"  => "/srv/salt"}, {"from" => "salt/pillar", "to" => "/srv/pillar"}]
minion_grains   = minion['default_grains']    || {}

# Default master/minion configs, overwritten by anything in the config
default_master_config = YAML.load("
  ipv6: false
  worker_threads: 3
  pidfile: '/var/run/salt-master.pid'
  timeout: 10
  loop_interval: 30
  auto_accept: true
  open_mode: true
  file_roots:
    base: ['/srv/salt']
  pillar_roots:
    base: ['/srv/pillar']
")

default_minion_config = YAML.load("
  master: #{network + '.10'}
  master_alive_interval: 9000
")

# Merge & override with options from the config
master_config = default_master_config.merge!(master_config)
minion_config = default_minion_config.merge!(minion_config)

# Create boxes
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Create Salt Master
  config.vm.define 'devmaster' do |master|
    master.vm.provider :lxc do |lxc|
      lxc.customize 'network.type', 'veth'
      lxc.customize 'network.link', bridge
      lxc.customize 'network.ipv4', "#{network}.10/24"
    end
    master.vm.hostname = 'saltmaster'
    master.vm.box = master_box
    if master_box_url
      master.vm.box_url = master_box_url
    end
    if master_folders
      master_folders.each do |folder|
        master.vm.synced_folder folder['from'], folder['to']
      end
    end
    master.vm.provision :salt do |salt|
      salt.minion_id         = 'devmaster'
      salt.install_type      = salt_version
      salt.install_args      = install_args
      salt.install_master    = true
      salt.bootstrap_options = "-J '#{master_config.to_json}' -j '{\"master\": \"localhost\"}'"
      salt.run_highstate     = false
      salt.verbose           = false
      if Vagrant.has_plugin?('salty-vagrant-grains')
        salt.grains(master_grains)
      end
    end
  end

  # Iterate through minions in YAML file
  # Start a counter, used for IPs
  count = 11
  minions.each do |minion|
    # Set minion options, or use defaults
    cpu       = minion['cpu']       || 1
    ram       = minion['ram']       || '512M'
    box       = minion['box']       || default_box
    box_url   = minion['box_url']   || false
    highstate = minion['highstate'] || false
    folders   = minion['folders']   || false
    grains    = minion['grains']    || {}
    ip        = "#{network.to_s}.#{count.to_s}/24"
    name      = "#{minion['name']}#{domain}"
    # Merge custom and default grains
    grains    = grains.merge(minion_grains)
    # Bump the counter
    count     += 1

    # Create the minion
    config.vm.define name do |minion|
      minion.vm.provider :lxc do |lxc|
        lxc.customize 'cgroup.cpuset.cpus', cpu
        lxc.customize 'cgroup.memory.limit_in_bytes', ram
        lxc.customize 'network.type', 'veth'
        lxc.customize 'network.link', bridge
        lxc.customize 'network.ipv4', ip
      end
      minion.vm.box = box
      if box_url
        minion.vm.box_url = box_url
      end
      minion.vm.hostname = name
      if folders
        for folder in folders
          minion.vm.synced_folder folder['from'], folder['to']
        end
      end
      # Install and configure the Salt Minion
      minion.vm.provision :salt do |salt|
        salt.minion_id         = name
        salt.install_type      = salt_version
        salt.install_args      = install_args
        salt.bootstrap_options = "-j '#{minion_config.to_json}'"
        salt.run_highstate     = highstate
        salt.verbose           = false
        if Vagrant.has_plugin?('salty-vagrant-grains')
          salt.grains(grains)
        end
      end
    end
  end
end
