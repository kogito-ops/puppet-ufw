class {'ufw':
  #service_ensure         => 'stopped',
  purge_unmanaged_rules  => true,
  purge_unmanaged_routes => true,
  rules                  => {
    'allow ssh connections'   => {
      'action'       => 'allow',
      'to_ports_app' => 22,
    },
    'enable incoming to http' => {
      'action'       => 'allow',
      'to_ports_app' => 81,
      'ensure'       => 'present',
    },
    'more complicated rule'   => {
      'ensure'         => 'present',
      'action'         => 'allow',
      'direction'      => 'out',
      'interface'      => 'eth0',
      'log'            => 'log',
      'from_addr'      => '10.1.3.0/24',
      'from_ports_app' => 3133,
      'to_addr'        => '10.3.3.3',
      'to_ports_app'   => 2122,
    },
  },
}

ufw_rule { 'allow ssh from internal networks':
  action         => 'allow',
  direction      => 'in',
  interface      => undef,
  log            => undef,
  from_addr      => '10.1.3.0/24',
  from_ports_app => 'OpenSSH',
  to_addr        => '10.3.0.1',
  to_ports_app   => 22,
}
