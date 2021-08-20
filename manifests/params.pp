# @summary Parameters for the ufw class
#
# Parameters for ufw class
#
# @api private
#
# @param [Boolean] manage_package
#   If the class should manage an ufw package.
# @param [String[1]] package_name
#   Ufw package to manage.
# @param [String[1]] package_ensure
#   What state the package should be in.
# @param [Boolean] manage_service
#   If the module should manage the ufw service state.
# @param [Stdlib::Ensure::Service] service_ensure
#   Defines the state of the ufw service.
# @param [String[1]] service_name
#   The name of the ufw service to manage.
# @param [Hash[String[1], Hash]] rules
#   Rule definitions to apply.
# @param [Hash[String[1], Hash]] routes
#   Routing definitions to apply.
# @param [Boolean] purge_unmanaged_rules
#   Defines if unmanaged rules should be purged. Default: false
# @param [Boolean] purge_unmanaged_routes
#   Defines if unmanaged routes should be purged. Default: false
# @param [Ufw::LogLevel] log_level
#   Logging level. Default: 'low'
# @param [Boolean] manage_default_config
#   If the module should manage /etc/default/ufw. Default: true
# @param [String[1]] default_config_content
#   Configuration content to put to /etc/default/ufw. Default is taken from files/default of this module.
# @param [Boolean] manage_logrotate_config
#   If the module should manage /etc/logrotate.d/ufw. Default: true
# @param [String[1]] logrotate_config_content
#   Configuration content to put to /etc/logrotate.d/ufw. Default is taken from files/logrotate of this module.
# @param [Boolean] manage_rsyslog_config
#   If the module should manage /etc/rsyslog.d/20-ufw.conf. Default: true
# @param [String[1]] rsyslog_config_content
#   Configuration content to put to /etc/rsyslog.d/20-ufw.conf. Default is taken from files/ufw of this module.
# @param [Boolean] manage_sysctl_config
#   If the module should manage /etc/ufw/sysctl.conf. Default: true
# @param [String[1]] sysctl_config_content
#   Configuration content to put to /etc/ufw/sysctl.conf. Default is taken from files/sysctl of this module.
# @param [Boolean] manage_before_rules
#   Controls if the module should manage /etc/ufw/before.rules. Default: true
# @param [String[1]] before_rules_content
#   Configuration content to put to /etc/ufw/before.rules. Default is taken from files/before.rules of this module.
# @param [Boolean] manage_before6_rules
#   Controls if the module should manage /etc/ufw/before6.rules. Default: true
# @param [String[1]] before6_rules_content
#   Configuration content to put to /etc/ufw/before6.rules. Default is taken from files/before6.rules of this module.
# @param [Boolean] manage_after_rules
#   Controls if the module should manage /etc/ufw/after.rules. Default: true
# @param [String[1]] after_rules_content
#   Configuration content to put to /etc/ufw/after.rules. Default is taken from files/after.rules of this module.
# @param [Boolean] manage_after6_rules
#   Controls if the module should manage /etc/ufw/after6.rules. Default: true
# @param [String[1]] after6_rules_content
#   Configuration content to put to /etc/ufw/after6.rules. Default is taken from files/after6.rules of this module.
#
class ufw::params(
  Boolean                         $manage_package              = true,
  String[1]                       $package_name                = 'ufw',
  String[1]                       $package_ensure              = 'present',
  Boolean                         $manage_service              = true,
  Stdlib::Ensure::Service         $service_ensure              = 'running',
  String[1]                       $service_name                = 'ufw',
  Hash[String[1], Hash]           $rules                       = {},
  Hash[String[1], Hash]           $routes                      = {},
  Boolean                         $purge_unmanaged_rules       = false,
  Boolean                         $purge_unmanaged_routes      = false,
  Ufw::LogLevel                   $log_level                   = 'low',
  Boolean                         $manage_default_config       = true,
  String[1]                       $default_config_content      = file('ufw/default'),
  Boolean                         $manage_logrotate_config     = true,
  String[1]                       $logrotate_config_content    = file('ufw/logrotate'),
  Boolean                         $manage_rsyslog_config       = true,
  String[1]                       $rsyslog_config_content      = file('ufw/rsyslog'),
  Boolean                         $manage_sysctl_config        = true,
  String[1]                       $sysctl_config_content       = file('ufw/sysctl'),
  Boolean                         $manage_before_rules         = true,
  String[1]                       $before_rules_content        = file('ufw/before.rules'),
  Boolean                         $manage_before6_rules        = true,
  String[1]                       $before6_rules_content       = file('ufw/before6.rules'),
  Boolean                         $manage_after_rules          = true,
  String[1]                       $after_rules_content         = file('ufw/after.rules'),
  Boolean                         $manage_after6_rules         = true,
  String[1]                       $after6_rules_content        = file('ufw/after6.rules'),
) {
}
