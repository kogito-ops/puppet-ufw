# @summary Manages ufw related configuration files
#
# Manages ufw related configuration files.
#
# @example
#   class {'ufw::config':
#     log_level                => 'low',
#     manage_default_config    => true,
#     default_config_content   => file('ufw/default'),
#     manage_logrotate_config  => true,
#     logrotate_config_content => file('ufw/logrotate'),
#     manage_rsyslog_config    => true,
#     rsyslog_config_content   => file('ufw/rsyslog'),
#     manage_sysctl_config     => true,
#     sysctl_config_content    => file('ufw/sysctl'),
#     manage_before_rules      => true,
#     before_rules_content     => file('ufw/before.rules'),
#     manage_before6_rules     => true,
#     before6_rules_content    => file('ufw/before6.rules'),
#     manage_after_rules       => true,
#     after_rules_content      => file('ufw/after.rules'),
#     manage_after6_rules      => true,
#     after6_rules_content     => file('ufw/after.rules'),
#   }
#
# @param [Ufw::LogLevel] log_level
#   Logging level. Default: 'low'
# @param [Boolean] manage_default_config
#   Controls if the module should manage /etc/default/ufw.
# @param [String[1]] default_config_content
#   Configuration content to put to /etc/default/ufw.
# @param [Boolean] manage_logrotate_config
#   Controls if the module should manage /etc/logrotate.d/ufw.
# @param [String[1]] logrotate_config_content
#   Configuration content to put to /etc/logrotate.d/ufw.
# @param [Boolean] manage_rsyslog_config
#   Controls if the module should manage /etc/rsyslog.d/20-ufw.conf.
# @param [String[1]] rsyslog_config_content
#   Configuration content to put to /etc/rsyslog.d/20-ufw.conf.
# @param [Boolean] manage_sysctl_config
#   Controls if the module should manage /etc/ufw/sysctl.conf.
# @param [String[1]] sysctl_config_content
#   Configuration content to put to /etc/ufw/sysctl.conf.
# @param [Boolean] manage_before_rules
#   Controls if the module should manage /etc/ufw/before.rules.
# @param [String[1]] before_rules_content
#   Configuration content to put to /etc/ufw/before.rules.
# @param [Boolean] manage_before6_rules
#   Controls if the module should manage /etc/ufw/before6.rules.
# @param [String[1]] before6_rules_content
#   Configuration content to put to /etc/ufw/before6.rules.
# @param [Boolean] manage_after_rules
#   Controls if the module should manage /etc/ufw/after.rules.
# @param [String[1]] after_rules_content
#   Configuration content to put to /etc/ufw/after.rules.
# @param [Boolean] manage_after6_rules
#   Controls if the module should manage /etc/ufw/after6.rules.
# @param [String[1]] after6_rules_content
#   Configuration content to put to /etc/ufw/after6.rules.
#
class ufw::config(
  Ufw::LogLevel         $log_level                        = $ufw::log_level,
  Boolean               $manage_default_config            = $ufw::manage_default_config,
  String[1]             $default_config_content           = $ufw::default_config_content,
  Boolean               $manage_logrotate_config          = $ufw::manage_logrotate_config,
  String[1]             $logrotate_config_content         = $ufw::logrotate_config_content,
  Boolean               $manage_rsyslog_config            = $ufw::manage_rsyslog_config,
  String[1]             $rsyslog_config_content           = $ufw::rsyslog_config_content,
  Boolean               $manage_sysctl_config             = $ufw::manage_sysctl_config,
  String[1]             $sysctl_config_content            = $ufw::sysctl_config_content,
  Boolean               $manage_before_rules              = $ufw::manage_before_rules,
  String[1]             $before_rules_content             = $ufw::before_rules_content,
  Boolean               $manage_before6_rules             = $ufw::manage_before6_rules,
  String[1]             $before6_rules_content            = $ufw::before6_rules_content,
  Boolean               $manage_after_rules               = $ufw::manage_after_rules,
  String[1]             $after_rules_content              = $ufw::after_rules_content,
  Boolean               $manage_after6_rules              = $ufw::manage_after6_rules,
  String[1]             $after6_rules_content             = $ufw::after6_rules_content,
) {
  if $manage_default_config {
    file {'/etc/default/ufw':
      path    => '/etc/default/ufw',
      content => $default_config_content,
    }
  }

  if $manage_logrotate_config {
    file {'/etc/logrotate.d/ufw':
      path    => '/etc/logrotate.d/ufw',
      content => $logrotate_config_content,
    }
  }

  if $manage_rsyslog_config {
    file {'/etc/rsyslog.d/20-ufw.conf':
      path    => '/etc/rsyslog.d/20-ufw.conf',
      content => $rsyslog_config_content,
    }
  }

  if $manage_sysctl_config {
    file {'/etc/ufw/sysctl.conf':
      path    => '/etc/ufw/sysctl.conf',
      content => $sysctl_config_content,
    }
  }

  if $manage_before_rules {
    file {'/etc/ufw/before.rules':
      path    => '/etc/ufw/before.rules',
      content => $before_rules_content,
    }
  }

  if $manage_before6_rules {
    file {'/etc/ufw/before6.rules':
      path    => '/etc/ufw/before6.rules',
      content => $before6_rules_content,
    }
  }

  if $manage_after_rules {
    file {'/etc/ufw/after.rules':
      path    => '/etc/ufw/after.rules',
      content => $after_rules_content,
    }
  }

  if $manage_after6_rules {
    file {'/etc/ufw/after6.rules':
      path    => '/etc/ufw/after6.rules',
      content => $after6_rules_content,
    }
  }

  file_line { 'loglevel':
    ensure => present,
    path   => '/etc/ufw/ufw.conf',
    line   => "LOGLEVEL=${log_level}",
    match  => '^LOGLEVEL\=',
  }
}
