# @summary The ufw class
#
# The ufw class controls state of the ufw installation and service in the system.
# It also applies firewall rules.
#
# @example
#   class {'ufw':
#     manage_package => true,
#     package_name   => 'ufw',
#     packege_ensure => 'present',
#     manage_service => 'true',
#     service_name   => 'ufw',
#     service_ensure => 'running',
#     rules          => {
#         'sample rule'              => {
#           'ensure'         => 'present',
#           'action'         => 'allow',
#           'direction'      => 'out',
#           'interface'      => 'eth0',
#           'log'            => 'log',
#           'from_addr'      => '10.1.3.0/24',
#           'from_ports_app' => 3133,
#           'to_addr'        => '10.3.3.3',
#           'to_ports_app'   => 2122,
#         },
#     }
#   }
#
# @param [Boolean] manage_package If the class should manage an ufw package.
# @param [String[1]] package_name Ufw package to manage.
# @param [String[1]] packege_ensure What state the package should be in.
# @param [Boolean] manage_service If the module should manage the ufw service state.
# @param [Stdlib::Ensure::Service] service_ensure Defines the state of the ufw service.
# @param [String[1]] service_name The name of the ufw service to manage.
# @param [Hash[String[1], Hash]] rules Rule definitions to apply
# @param [Hash[String[1], Hash]] routes Routing definitions to apply
#
class ufw(
  Boolean                    $manage_package = $ufw::params::manage_package,
  String[1]                  $package_name   = $ufw::params::package_name,
  String[1]                  $packege_ensure = $ufw::params::package_ensure,
  Boolean                    $manage_service = $ufw::params::manage_service,
  Stdlib::Ensure::Service    $service_ensure = $ufw::params::service_ensure,
  String[1]                  $service_name   = $ufw::params::service_name,
  Hash[String[1], Hash]      $rules          = $ufw::params::rules,
  Hash[String[1], Hash]      $routes         = $ufw::params::routes,
) inherits ufw::params {
  include ::ufw::install
  include ::ufw::service

  $rules.each | $rule, $rule_values | {
    ufw_rule {$rule:
      * => $rule_values,
    }
  }

  $routes.each | $route, $route_values | {
    ufw_route {$route:
      * => $route_values,
    }
  }

  Class['ufw::install']
    -> Class['ufw::service']
}
