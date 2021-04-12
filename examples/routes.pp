class {'ufw':
  # service_ensure => 'stopped',
  routes          => {
    'route everything from anywhere on vpn to anywhere on internal net' => {
      'ensure'        => 'present',
      'action'        => 'allow',
      'interface_in'  => 'tun0',
      'interface_out' => 'eth0',
    },
    'route ssh from anywhere to 10.5.0.0/24 with log'                   => {
      'ensure'         => 'present',
      'action'         => 'allow',
      'interface_in'   => 'any',
      'interface_out'  => 'any',
      'log'            => 'log',
      'from_addr'      => 'any',
      'from_ports_app' => undef,
      'to_addr'        => '10.5.0.0/24',
      'to_ports_app'   => undef,
    },
  }
}
