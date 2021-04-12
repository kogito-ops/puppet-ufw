# @summary Manages ufw service
#
# Manages ufw service.
#
# @example
#   class {'ufw::service':
#     manage_service => true,
#     service_ensure => 'running',
#     service_name   => 'ufw',
#   }
#
# @param [Boolean] manage_service If the module should manage the ufw service state.
# @param [Stdlib::Ensure::Service] service_ensure Defines the state of the ufw service.
# @param [String[1]] service_name The name of the ufw service to manage.
#
class ufw::service(
  Boolean                    $manage_service = $ufw::manage_service,
  Stdlib::Ensure::Service    $service_ensure = $ufw::service_ensure,
  String[1]                  $service_name   = $ufw::service_name,
) {
  if $manage_service {
    if $service_ensure == 'stopped' {
      $action = 'disable'
      $unless_status = 'inactive'
    } else {
      $action = 'enable'
      $unless_status = 'active'
    }

    service { $service_name:
      ensure    => $service_ensure,
    }
    #TODO investigate the reasons behind https://github.com/attachmentgenie/attachmentgenie-ufw/blob/master/manifests/service.pp#L17-L22
    -> exec { "ufw --force ${action}":
      path        => '/usr/sbin:/bin',
      environment => ['DEBIAN_FRONTEND=noninteractive'],
      unless      => "ufw status | grep 'Status: ${unless_status}'",
    }
  }
}
