# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include ufw
class ufw(
  Boolean $manage_package = $ufw::params::manage_package,
  String[1] $package_name = $ufw::params::package_name,
  String[1] $packege_ensure = $ufw::params::package_ensure,
  Boolean $manage_service = $ufw::params::manage_service,
  Stdlib::Ensure::Service $service_ensure = $ufw::params::service_ensure,
  String[1] $service_name = $ufw::params::service_name,
) inherits ufw::params {
  include ::ufw::install
  include ::ufw::service

  Class['ufw::install']
    -> Class['ufw::service']
}
