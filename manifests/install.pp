# @summary Manages ufw package
#
# This class manages ufw package installation.
#
# @example
#   class {'ufw::install':
#     manage_package => true,
#     package_name   => 'ufw',
#     packege_ensure => 'present',
#   }
#
# @param [Boolean] manage_package If the class should manage an ufw package.
# @param [String[1]] package_name Ufw package to manage.
# @param [String[1]] packege_ensure What state the package should be in.
#
class ufw::install(
  Boolean   $manage_package = $ufw::manage_package,
  String[1] $package_name   = $ufw::package_name,
  String[1] $packege_ensure = $ufw::packege_ensure,
) {
  if $manage_package {
    package {$package_name:
      ensure => $packege_ensure,
    }
  }
}
