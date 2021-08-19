# frozen_string_literal: true

# run a test task
require 'spec_helper_acceptance'

describe 'ufw::service' do
  before(:all) do
    # Need to disable ipv6 to avoid issues with missing ipv6 on ubuntu on github runners
    bolt_upload_file(
      File.expand_path(File.join(__FILE__, '../../fixtures/files/default')),
      '/etc/puppetlabs/code/environments/production/modules/ufw/files/default',
    )
    pp = <<-MANIFEST
    include ufw

    ufw_rule { 'allow ssh':
      action         => 'allow',
      to_ports_app   => 22,
    }
    MANIFEST
    apply_manifest(pp)
  end

  context 'service management' do
    context 'can enable service' do
      let(:pp) do
        <<-MANIFEST
        class {'ufw::service':
          manage_service => true,
          service_ensure => 'running',
          service_name   => 'ufw',
        }
        MANIFEST
      end

      it 'applies idempotently' do
        idempotent_apply(pp)
      end

      describe service('ufw') do
        it {
          is_expected.to be_enabled
          is_expected.to be_running
        }
      end
    end

    context 'can disable service' do
      let(:pp) do
        <<-MANIFEST
        class {'ufw::service':
          manage_service => true,
          service_ensure => 'stopped',
          service_name   => 'ufw',
        }
        MANIFEST
      end

      it 'applies idempotently' do
        idempotent_apply(pp)
      end

      describe service('ufw') do
        it {
          is_expected.not_to be_running
        }
      end
    end

    context 'ignores unmanaged service' do
      let(:pp_disable) do
        <<-MANIFEST
        class {'ufw::service':
          manage_service => true,
          service_ensure => 'stopped',
          service_name   => 'ufw',
        }
        MANIFEST
      end
      let(:pp) do
        <<-MANIFEST
        class {'ufw::service':
          manage_service => false,
          service_ensure => 'running',
          service_name   => 'ufw',
        }
        MANIFEST
      end

      it 'applies idempotently' do
        apply_manifest(pp_disable)
        idempotent_apply(pp)
      end

      describe service('ufw') do
        it {
          is_expected.not_to be_running
        }
      end
    end
  end
end
