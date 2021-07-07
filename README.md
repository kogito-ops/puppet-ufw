# ufw

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with ufw](#setup)
    * [What ufw affects](#what-ufw-affects)
    * [Setup requirements](#setup-requirements)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development-and-contribution)
1. [License](#license)

## Description

The ufw module manages the [uncomplicated firewall][] (ufw). It allows to control
netfilter rules (via `ufw_rule` resource) and routes (via `ufw_route` resource) as
well as to manage ufw related configuration files.

This module succeeds the original [attachmentgenie-ufw][] module that is now deprecated.

The key improvements:

* supports `ufw route`
* supports ufw framework (`after.rules`, `before.rules`, etc)
* supports purging unmanaged routes and rules


See [limitations](#limitations) for the unsupported functionality.

## Setup

### What ufw affects

* Ufw rule and route settings of managed nodes.
* Configuration files (`/etc/default/ufw`, `/etc/logrotate.d/ufw`, `/etc/rsyslog.d/20-ufw.conf`, `/etc/ufw/sysctl.conf`).
* Custom rule files (`after.rules`, `after6.rules`, `before.rules`, `before6.rules`).
* Purges unmanaged ufw rules (if selected to purge).
* Purges unmanaged ufw routing rules (if selected to purge).
* Ufw package and service.

### Setup requirements

The ufw module does not require any specific setup to be used.

## Usage

**Warning**: UFW denies incoming traffic by default, so it locks out users unless
provided a rule that allows remote management (ssh, etc).

### Basic

```puppet
class {'ufw':
  purge_unmanaged_rules  => true,
  purge_unmanaged_routes => true,
  rules                  => {
    'allow ssh connections' => {
      'action'       => 'allow',
      'to_ports_app' => 22,
    },
  }
}
```

### Full

Entries in the `rules` accept the same parameters as `ufw_rule` does.

Entries in the `routes` accept the same parameters as `ufw_route` does.

Addresses support both individual hosts (`10.1.3.1`) and networks (`10.1.3.0/24`)
in ipv4 and ipv6 formats.

To specify a list of ports, separate them with a comma without whitespaces: `80,443`

To specify a range of ports, separate them by a colon without whitespaces: `8080:8085`

Check [REFERENCE.md][] for the parameter descriptions.

```puppet
class {'ufw':
  manage_package           => true,
  package_name             => 'ufw',
  packege_ensure           => 'present',
  manage_service           => true,
  service_name             => 'ufw',
  service_ensure           => 'running',
  rules                    => {
    'sample rule' => {
      'ensure'         => 'present',
      'action'         => 'allow',
      'direction'      => 'out',
      'interface'      => 'eth0',
      'log'            => 'log',
      'from_addr'      => '10.1.3.0/24',
      'from_ports_app' => 3133,
      'to_addr'        => '10.3.3.3',
      'to_ports_app'   => 2122,
      'proto'          => 'tcp'
    },
  },
  routes                   => {
    'sample route' => {
      'ensure'         => 'present',
      'action'         => 'allow',
      'interface_in'   => 'any',
      'interface_out'  => 'any',
      'log'            => 'log',
      'from_addr'      => 'any',
      'from_ports_app' => undef,
      'to_addr'        => '10.5.0.0/24',
      'to_ports_app'   => undef,
      'proto'          => 'any',
    },
  },
  purge_unmanaged_rules    => true,
  purge_unmanaged_routes   => true,
  manage_default_config    => true,
  default_config_content   => file('ufw/default'),
  manage_logrotate_config  => true,
  logrotate_config_content => file('ufw/logrotate'),
  manage_rsyslog_config    => true,
  rsyslog_config_content   => file('ufw/rsyslog'),
  manage_sysctl_config     => true,
  sysctl_config_content    => file('ufw/sysctl'),
  manage_before_rules      => true,
  before_rules_content     => file('ufw/before.rules'),
  manage_before6_rules     => true,
  before6_rules_content    => file('ufw/before6.rules'),
  manage_after_rules       => true,
  after_rules_content      => file('ufw/after.rules'),
  manage_after6_rules      => true,
  after6_rules_content     => file('ufw/after6.rules'),
}
```

### ufw_rule simple usage

```puppet
ufw_rule { 'allow ssh':
  action         => 'allow',
  to_ports_app   => 22,
}

ufw_rule { 'allow https on eth1':
  action         => 'allow',
  to_ports_app   => 443,
  interface      => 'eth1'
}
```

### ufw_rule usage

`ufw_rule` controls regular, non-routing rules.

**Important**: The default action is `reject` for both `ufw_rule` and `ufw_route`.
So the traffic is rejected if `action` parameter is omitted.


```puppet
ufw_rule { 'allow ssh from internal networks':
  ensure         => 'present',
  action         => 'allow',
  direction      => 'in',
  interface      => undef,
  log            => undef,
  from_addr      => '10.1.3.0/24',
  from_ports_app => 'any',
  to_addr        => '10.3.0.1',
  to_ports_app   => 22,
  proto          => 'tcp',
}
```

### ufw_route usage

`ufw_route` controls routing rules.

```puppet
ufw_route { 'route vpn traffic to internal net':
  ensure         => 'present',
  action         => 'allow',
  interface_in   => 'tun0',
  interface_out  => 'eth0',
  log            => 'log',
  from_addr      => 'any',
  from_ports_app => undef,
  to_addr        => '10.5.0.0/24',
  to_ports_app   => undef,
  proto          => 'any',
}
```

## Reference

See [REFERENCE.md][].

## Limitations

* The module does not handle ordering. The rules are added in the order they provided.
* It's possible to update a rule, but the update is performed through recreation which changes ordering.
* Comment field is used as a rule/route name. Duplicate comments may cause unexpected behavior.


## Development and Contribution

See [DEVELOPMENT.md][].


## License

[MIT][]


[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
[uncomplicated firewall]: https://code.launchpad.net/ufw
[DEVELOPMENT.md]: DEVELOPMENT.md
[REFERENCE.md]: REFERENCE.md
[attachmentgenie-ufw]: https://forge.puppet.com/modules/attachmentgenie/ufw
[MIT]: LICENSE
