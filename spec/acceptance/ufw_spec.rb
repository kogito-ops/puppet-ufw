# frozen_string_literal: true

# run a test task
require 'spec_helper_acceptance'

describe 'ufw' do
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
      log_level                => 'high',
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
      it {
        is_expected.to be_enabled
        is_expected.to be_running
      }
    end

    describe command('ufw status') do
      its(:stdout) { is_expected.to contain('Status: active') }
    end
  end

  context 'with explicit params' do
    it 'applies idempotently' do
      idempotent_apply(pp_explicit)
    end

    describe command('ufw status verbose') do
      its(:stdout) do
        is_expected.to contain('Status: active')
        is_expected.to contain('Logging: on \(high\)')
      end
    end
  end

  context 'with purge_unmanaged_rules => true' do
    let(:manifest) do
      <<-MANIFEST
      class {'ufw':
        purge_unmanaged_rules    => true,
        rules                    => {
          'allow ssh' => {
            'action'         => 'allow',
            'to_ports_app'   => 22,
          },
        }
      }
      MANIFEST
    end

    it 'purges unmanaged rules' do
      apply_manifest(manifest)
      run_shell('ufw allow from 10.0.0.0/24 port 111 to 10.0.1.0/24')
      pre_run_result = run_shell('ufw show added')
      apply_manifest(manifest)

      expect(pre_run_result.stdout).to match(%r{allow from 10.0.0.0/24 port 111 to 10.0.1.0/24})
    end

    describe command('ufw show added') do
      its(:stdout) { is_expected.not_to contain('ufw allow from 10.0.0.0/24 port 111 to 10.0.1.0/24') }
    end
  end

  context 'with purge_unmanaged_routes => true' do
    let(:manifest) do
      <<-MANIFEST
      class {'ufw':
        purge_unmanaged_routes    => true,
        routes                    => {
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
        rules                    => {
          'allow ssh' => {
            'action'         => 'allow',
            'to_ports_app'   => 22,
          },
        }
      }
      MANIFEST
    end

    it 'purges unmanaged routes' do
      apply_manifest(manifest)
      run_shell('ufw route allow in on eth0 from any port 131:137 to 10.0.0.0/24 proto tcp')
      pre_run_result = run_shell('ufw show added')
      apply_manifest(manifest)

      expect(pre_run_result.stdout).to match(%r{ufw route allow in on eth0 from any port 131:137 to 10.0.0.0/24 proto tcp})
    end

    describe command('ufw show added') do
      its(:stdout) { is_expected.not_to contain('ufw route allow in on eth0 from any port 131:137 to 10.0.0.0/24 proto tcp') }
    end
  end

  def self.test_framework_file(name, file, template)
    context "installs #{name} from module when no custom provided" do
      let(:pp) do
        <<-MANIFEST
          class {'ufw':
            service_ensure    => 'stopped',
            manage_#{name}    => true,
          }
          MANIFEST
      end

      it 'applies' do
        apply_manifest(pp)
      end

      describe file(file) do
        it {
          is_expected.to be_file
        }
        its(:content) do
          is_expected.to contain 'THIS FILE IS MANAGED BY PUPPET. ALL CHANGES WILL BE DISCARDED.'
        end
      end
    end

    context "installs custom #{name} when provided" do
      let(:pp) do
        <<-MANIFEST
          class {'ufw':
            service_ensure    => 'stopped',
            manage_#{name}    => true,
            #{name}_content   => "${file('#{template}')} # THIS IS TEST CONTENT",
          }
          MANIFEST
      end

      it 'applies' do
        apply_manifest(pp)
      end

      describe file(file) do
        it {
          is_expected.to be_file
        }
        its(:content) do
          is_expected.to contain '# THIS IS TEST CONTENT'
        end
      end
    end

    context "does not overwrite #{name} if unmanaged" do
      let(:pp_pre) do
        <<-MANIFEST
          class {'ufw':
            service_ensure => 'stopped',
          }
          MANIFEST
      end

      let(:pp) do
        <<-MANIFEST
          class {'ufw':
            manage_#{name}  => false,
            #{name}_content => "${file('#{template}')} # THIS IS TEST CONTENT",
            service_ensure  => 'stopped',
          }
          MANIFEST
      end

      it 'applies' do
        apply_manifest(pp_pre)
        apply_manifest(pp)
      end

      describe file(file) do
        it {
          is_expected.to be_file
        }
        its(:content) do
          is_expected.not_to contain '# THIS IS TEST CONTENT'
        end
      end
    end
  end

  test_framework_file 'default_config', '/etc/default/ufw', 'ufw/default'
  test_framework_file 'logrotate_config', '/etc/logrotate.d/ufw', 'ufw/logrotate'
  test_framework_file 'rsyslog_config', '/etc/rsyslog.d/20-ufw.conf', 'ufw/rsyslog'
  test_framework_file 'sysctl_config', '/etc/ufw/sysctl.conf', 'ufw/sysctl'
  test_framework_file 'before_rules', '/etc/ufw/before.rules', 'ufw/before.rules'
  test_framework_file 'before6_rules', '/etc/ufw/before6.rules', 'ufw/before6.rules'
  test_framework_file 'after_rules', '/etc/ufw/after.rules', 'ufw/after.rules'
  test_framework_file 'after6_rules', '/etc/ufw/after6.rules', 'ufw/after6.rules'
end
