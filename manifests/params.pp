# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include ufw::params
class ufw::params(
  Boolean $manage_package = true,
  String[1] $package_name = 'ufw',
  String[1] $package_ensure = 'present',
  Boolean $manage_service = true,
  Stdlib::Ensure::Service $service_ensure = 'running',
  String[1] $service_name = 'ufw',
) {
}
