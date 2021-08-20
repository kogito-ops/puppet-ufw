# frozen_string_literal: true

require 'spec_helper'

describe 'ufw::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          log_level: 'low',
          manage_default_config: true,
          default_config_content: 'default',
          manage_logrotate_config: true,
          logrotate_config_content: 'logrotate',
          manage_rsyslog_config: true,
          rsyslog_config_content: 'rsyslog',
          manage_sysctl_config: true,
          sysctl_config_content: 'sysctl',
          manage_before_rules: true,
          before_rules_content: 'before',
          manage_before6_rules: true,
          before6_rules_content: 'before6',
          manage_after_rules: true,
          after_rules_content: 'after',
          manage_after6_rules: true,
          after6_rules_content: 'after6',
        }
      end

      it { is_expected.to compile }
    end
  end
end
