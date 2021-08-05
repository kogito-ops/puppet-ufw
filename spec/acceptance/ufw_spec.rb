# frozen_string_literal: true

# run a test task
require 'spec_helper_acceptance'

describe 'ufw', if: ['debian', 'ubuntu'].include?(os[:family]) do
  before(:all) do
    # Need to disable ipv6 to avoid issues with missing ipv6 on ubuntu on github runners
    bolt_upload_file(
      File.expand_path(File.join(__FILE__, '../../fixtures/files/default')),
      '/etc/puppetlabs/code/environments/production/modules/ufw/files/default',
    )
  end

  let(:pp) do
    <<-MANIFEST
      include ufw

      ufw_rule { 'allow ssh':
        action         => 'allow',
        to_ports_app   => 22,
      }
    MANIFEST
  end

  let(:pp_explicit) do
    <<-MANIFEST
    class {'ufw':
      manage_package           => true,
      package_name             => 'ufw',
      packege_ensure           => 'present',
      manage_service           => true,
      service_name             => 'ufw',
      service_ensure           => 'running',
      rules                    => {
        'sample rule' => {
          'ensure'         => 'present',
          'action'         => 'allow',
          'direction'      => 'out',
          'interface'      => 'eth0',
          'log'            => 'log',
          'from_addr'      => '10.1.3.0/24',
          'from_ports_app' => 3133,
          'to_addr'        => '10.3.3.3',
          'to_ports_app'   => 2122,
          'proto'          => 'tcp'
        },
        'allow ssh' => {
          'action'         => 'allow',
          'to_ports_app'   => 22,
        },
      },
      routes                   => {
        'sample route' => {
          'ensure'         => 'present',
          'action'         => 'allow',
          'interface_in'   => 'any',
          'interface_out'  => 'any',
          'log'            => 'log',
          'from_addr'      => 'any',
          'from_ports_app' => undef,
          'to_addr'        => '10.5.0.0/24',
          'to_ports_app'   => undef,
          'proto'          => 'any',
        },
      },
      purge_unmanaged_rules    => true,
      purge_unmanaged_routes   => true,
      manage_default_config    => true,
      default_config_content   => file('ufw/default'),
      manage_logrotate_config  => true,
      logrotate_config_content => file('ufw/logrotate'),
      manage_rsyslog_config    => true,
      rsyslog_config_content   => file('ufw/rsyslog'),
      manage_sysctl_config     => true,
      sysctl_config_content    => file('ufw/sysctl'),
      manage_before_rules      => true,
      before_rules_content     => file('ufw/before.rules'),
      manage_before6_rules     => true,
      before6_rules_content    => file('ufw/before6.rules'),
      manage_after_rules       => true,
      after_rules_content      => file('ufw/after.rules'),
      manage_after6_rules      => true,
      after6_rules_content     => file('ufw/after6.rules'),
    }
    MANIFEST
  end

  context 'with default params' do
    it 'applies idempotently' do
      idempotent_apply(pp)
    end

    describe service('ufw') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe command('ufw status') do
      its(:stdout) { is_expected.to contain('Status: active') }
    end
  end

  context 'with explicit params' do
    it 'applies idempotently' do
      idempotent_apply(pp_explicit)
    end
  end
end
