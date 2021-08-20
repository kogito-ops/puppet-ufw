# frozen_string_literal: true

require 'spec_helper'

describe 'ufw::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          manage_service: true,
          service_ensure: 'running',
          service_name: 'ufw',
        }
      end

      context 'with service_ensure => running' do
        it {
          is_expected.to compile
          is_expected.to contain_service('ufw').with('ensure' => 'running')
          is_expected.to contain_exec('Disable ufw to force config reload').with('refreshonly' => true, 'unless' => "ufw status | grep 'Status: inactive'").that_requires('Service[ufw]')
          is_expected.to contain_exec('ufw --force enable').with_unless("ufw status | grep 'Status: active'").that_requires(['Exec[Disable ufw to force config reload]', 'Service[ufw]'])
        }
      end

      context 'with service_ensure => stopped' do
        let(:params) do
          super().merge({
                          service_ensure: 'stopped',
                        })
        end

        it {
          is_expected.to compile
          is_expected.to contain_service('ufw').with('ensure' => 'stopped')
          is_expected.to contain_exec('Disable ufw to force config reload').with('refreshonly' => true, 'unless' => "ufw status | grep 'Status: inactive'").that_requires('Service[ufw]')
          is_expected.to contain_exec('ufw --force disable').with_unless("ufw status | grep 'Status: inactive'").that_requires(['Exec[Disable ufw to force config reload]', 'Service[ufw]'])
        }
      end

      context 'with manage_service => false' do
        let(:params) do
          super().merge({
                          manage_service: false,
                        })
        end

        it {
          is_expected.to compile
          is_expected.to have_resource_count(0)
        }
      end
    end
  end
end
