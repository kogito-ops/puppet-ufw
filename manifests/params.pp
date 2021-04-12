# @summary Parameters for the ufw class
#
# Parameters for ufw class
#
# @api private
#
# @param [Boolean] manage_package If the class should manage an ufw package.
# @param [String[1]] package_name Ufw package to manage.
# @param [String[1]] packege_ensure What state the package should be in.
# @param [Boolean] manage_service If the module should manage the ufw service state.
# @param [Stdlib::Ensure::Service] service_ensure Defines the state of the ufw service.
# @param [String[1]] service_name The name of the ufw service to manage.
# @param [Hash[String[1], Hash]] rules Rule definitions to apply
#
class ufw::params(
  Boolean                         $manage_package    = true,
  String[1]                       $package_name      = 'ufw',
  String[1]                       $package_ensure    = 'present',
  Boolean                         $manage_service    = true,
  Stdlib::Ensure::Service         $service_ensure    = 'running',
  String[1]                       $service_name      = 'ufw',
  Hash[String[1], Hash]           $rules             = {},
) {
}
