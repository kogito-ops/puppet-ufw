# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::UfwRule')
require 'puppet/provider/ufw_rule/ufw_rule'

RSpec.describe Puppet::Provider::UfwRule::UfwRule do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  let(:added_rules) do
    <<-UFW_OUTPUT
    ufw allow 3133
    UFW_OUTPUT
  end

  let(:added_simple_rules) do
    <<-UFW_OUTPUT
    ufw allow 3133
    ufw deny 8080/tcp
    ufw allow out 80,443/tcp
    ufw allow log 555,777/tcp
    ufw allow out log-all 1111
    UFW_OUTPUT
  end

  let(:added_rules_full) do
    <<-UFW_OUTPUT
    ufw allow 3133
    ufw deny 8080/tcp comment 'testing'
    ufw allow out 80,443/tcp
    ufw allow log 555,777/tcp
    ufw allow out log-all 1111
    ufw allow log from any port 555,777 to any port 555,777 proto tcp
    ufw allow out from 10.1.3.3 port 3133
    ufw allow out on eth1 from 10.1.3.3 port 3133 to 10.3.3.3 port 2122
    ufw route allow to 10.1.3.0/24
    ufw allow from 10.1.3.0/24 proto gre
    ufw allow to any proto gre
    ufw allow from 10.5.3.0/24 proto gre comment 'test 1'
    UFW_OUTPUT
  end

  let(:sample_rule) do
    {
      ensure: 'present',
      name: 'foo',
      action: 'allow',
      direction: 'in',
      interface: nil,
      log: nil,
      from_addr: 'any',
      from_ports_app: nil,
      to_addr: 'any',
      to_ports_app: nil,
      proto: 'any',
    }
  end

  # TODO: add app to spec

  before :each do
    Puppet::Util::ExecutionStub.set do |command, _options|
      added_rules_full if command == ['/usr/sbin/ufw', 'show', 'added']
    end
  end

  # describe '#get' do
  #   # it 'processes resources' do
  #   #   expect(context).to receive(:debug)#.with('Returning pre-canned example data')
  #   #   expect(provider.get(context)).to eq [
  #   #     {
  #   #       name: 'foo',
  #   #       ensure: 'present',
  #   #       action: 'allow',
  #   #       direction: 'in',
  #   #       interface: nil,
  #   #       log: nil,
  #   #       from_addr: 'any',
  #   #       from_ports_app: nil,
  #   #       to_addr: 'any',
  #   #       to_ports_app: nil,
  #   #       proto: 'any',
  #   #     },
  #   #     {
  #   #       name: 'bar',
  #   #       ensure: 'present',
  #   #     },
  #   #   ]
  #   # end

  #   # it 'processes simple rules' do
  #   #   Puppet::Util::ExecutionStub.set do |command, _options|
  #   #     added_simple_rules if command === ['/usr/sbin/ufw', 'show', 'added']
  #   #   end

  #   #   expect(provider.get(context)).to eq [
  #   #     {
  #   #       name: 'foo',
  #   #       ensure: 'present',
  #   #       action: 'allow',
  #   #       direction: 'in',
  #   #       interface: nil,
  #   #       log: nil,
  #   #       from_addr: 'any',
  #   #       from_ports_app: nil,
  #   #       to_addr: 'any',
  #   #       to_ports_app: nil,
  #   #       proto: 'any',
  #   #     },
  #   #     {
  #   #       name: 'bar',
  #   #       ensure: 'present',
  #   #     },
  #   #   ]
  #   # end
  # end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      expect(context).to receive(:notice).with(%r{\ACreating 'a'})

      provider.create(context, 'a', name: 'a', ensure: 'present')
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      provider.instance_variable_set(:@instances, [sample_rule])

      expect(context).to receive(:notice).with(%r{\AUpdating 'foo'})

      provider.update(context, 'foo', name: 'foo', ensure: 'present')
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      provider.instance_variable_set(:@instances, [sample_rule])

      expect(context).to receive(:notice).with(%r{\ADeleting 'foo'})

      provider.delete(context, 'foo')
    end
  end

  describe 'rule_to_hash(context, line)' do
    it 'parses line in full syntax' do
      expect(provider.rule_to_hash(nil, "ufw allow from 10.5.3.0/24 proto gre comment 'test 1'")).to eq({
                                                                                                          ensure: 'present',
        name: 'test 1',
        action: 'allow',
        direction: 'in',
        interface: nil,
        log: nil,
        from_addr: '10.5.3.0/24',
        from_ports_app: nil,
        to_addr: 'any',
        to_ports_app: nil,
        proto: 'gre',
                                                                                                        })
    end

    it 'parses line in short syntax' do
      expect(provider.rule_to_hash(nil, "ufw allow log 555,777/tcp comment 'test 1'")).to eq({
                                                                                               ensure: 'present',
        name: 'test 1',
        action: 'allow',
        direction: 'in',
        interface: nil,
        log: 'log',
        from_addr: 'any',
        from_ports_app: nil,
        to_addr: 'any',
        to_ports_app: '555,777',
        proto: 'tcp',
                                                                                             })
    end
  end
end
