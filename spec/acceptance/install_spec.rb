# frozen_string_literal: true

# run a test task
require 'spec_helper_acceptance'

describe 'ufw::install' do
  before(:all) do
    # Need to disable ipv6 to avoid issues with missing ipv6 on ubuntu on github runners
    bolt_upload_file(
      File.expand_path(File.join(__FILE__, '../../fixtures/files/default')),
      '/etc/puppetlabs/code/environments/production/modules/ufw/files/default',
    )
  end

  context 'with manage_package => true' do
    context 'package installation' do
      let(:pp) do
        <<-MANIFEST
        class {'ufw::install':
          manage_package => true,
          package_name => 'ufw',
          packege_ensure => 'present',
        }
        MANIFEST
      end

      it 'applies idempotently' do
        idempotent_apply(pp)
      end

      describe package('ufw') do
        it { is_expected.to be_installed }
      end
    end

    context 'package uninstallation' do
      let(:pp) do
        <<-MANIFEST
        class {'ufw::install':
          manage_package => true,
          package_name => 'ufw',
          packege_ensure => 'absent',
        }
        MANIFEST
      end

      it 'applies idempotently' do
        idempotent_apply(pp)
      end

      describe package('ufw') do
        it { is_expected.not_to be_installed }
      end
    end
  end

  context 'with manage_package => false' do
    let(:pp) do
      <<-MANIFEST
      class {'ufw::install':
        manage_package => false,
        package_name => 'ufw',
        packege_ensure => 'present',
      }
      MANIFEST
    end

    it 'does not manage package' do
      idempotent_apply(pp)
    end

    describe package('ufw') do
      it { is_expected.not_to be_installed }
    end
  end
end
