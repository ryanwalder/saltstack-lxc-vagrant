# 2.0.0

Major refactor

* Move minions to be under `minions` key in yaml
* Explicitly set lxc as the vagrant provider
* Make vagrant-salty-grains optional
* Move settings to yaml file
* Add settings which can be configured from the YAML file:
    1. salt_version
    2. domain
    3. default_box
    4. default_box_url
    5. master_box
    6. master_box_url
    7. network
    8. bridge
    9. master_grains
    10. minion_grains
* Remove static master/minion configs
    * Add defaults to vagrant file
    * Configs merged with configs specified in YAML
* Add defaults for all options
* Code cleanup to make things easier to read
* Remove specifying IPs, just increment within the loop
* Remove example folders
* Rename `saltmaster to `devmaster` as we might spin up a saltmaster as
  a minion which should avoid name clashes and confusion.
