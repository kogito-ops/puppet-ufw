# frozen_string_literal: true

# run a test task
require 'spec_helper_acceptance'

describe 'default ufw install', if: ['debian', 'ubuntu'].include?(os[:family]) do
  let(:pp) do
    <<-MANIFEST
      include ufw

      ufw_rule { 'allow ssh':
        action         => 'allow',
        to_ports_app   => 22,
      }
    MANIFEST
  end

  it 'applies idempotently' do
    idempotent_apply(pp)
  end

  describe package('ufw') do
    it { should be_installed }
  end

  describe service('ufw') do
    it { should be_enabled }
    it { should be_running }
  end

  describe command('ufw status') do
    its(:stdout) { should contain('Status: active') }
  end
end
