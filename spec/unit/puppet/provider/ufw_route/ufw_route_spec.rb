# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::UfwRoute')
require 'puppet/provider/ufw_route/ufw_route'

RSpec.describe Puppet::Provider::UfwRoute::UfwRoute do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  let(:sample_route) do
    {
      ensure: 'present',
      name: 'foo',
      action: 'allow',
      interface_in: 'tun0',
      interface_out: 'eth1',
      log: nil,
      from_addr: 'any',
      from_ports_app: nil,
      to_addr: 'any',
      to_ports_app: nil,
      proto: 'any',
    }
  end

  let(:added_rules) do
    <<-UFW_OUTPUT
    ufw route allow in on eth0 comment 'wat'
    ufw route allow in on eth0 from any port 131,132 to 10.0.0.0/24 proto tcp comment 'wat'
    ufw route allow in on eth0 from any app OpenSSH to 10.5.0.0/24 comment 'wat'
    UFW_OUTPUT
  end

  before :each do
    Puppet::Util::ExecutionStub.set do |_command, _options|
      ''
    end
  end

  # describe '#get' do
  #   it 'processes resources' do
  #     expect(context).to receive(:debug).with('Returning pre-canned example data')
  #     expect(provider.get(context)).to eq [
  #       {
  #         name: 'foo',
  #         ensure: 'present',
  #       },
  #       {
  #         name: 'bar',
  #         ensure: 'present',
  #       },
  #     ]
  #   end
  # end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      expect(context).to receive(:notice).with(%r{\ACreating 'a'})

      provider.create(context, 'a', name: 'a', ensure: 'present')
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      provider.instance_variable_set(:@instances, [sample_route])

      expect(context).to receive(:notice).with(%r{\AUpdating 'foo'})

      provider.update(context, 'foo', name: 'foo', ensure: 'present')
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      provider.instance_variable_set(:@instances, [sample_route])

      expect(context).to receive(:notice).with(%r{\ADeleting 'foo'})

      provider.delete(context, 'foo')
    end
  end

  describe 'rule_to_hash(context, line)' do
    it 'parses line with basic parameters' do
      expect(provider.rule_to_hash(nil, "ufw route allow in on eth0 comment 'test 1'")).to eq(
        {
          ensure: 'present',
          name: 'test 1',
          action: 'allow',
          interface_in: 'eth0',
          interface_out: nil,
          log: nil,
          from_addr: 'any',
          from_ports_app: nil,
          to_addr: 'any',
          to_ports_app: nil,
          proto: 'any',
        },
      )
    end

    # it 'parses line in short syntax' do
    #   expect(provider.rule_to_hash(nil, "ufw allow log 555,777/tcp comment 'test 1'")).to eq(
    #     {
    #       ensure: 'present',
    #       name: 'test 1',
    #       action: 'allow',
    #       direction: 'in',
    #       interface: nil,
    #       log: nil,
    #       from_addr: '10.5.3.0/24',
    #       from_ports_app: nil,
    #       to_addr: 'any',
    #       to_ports_app: nil,
    #       proto: 'gre',
    #     }
    #   )
    # end
  end
end
