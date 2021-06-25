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

  let(:added_routes) do
    <<-UFW_OUTPUT
    Added user rules (see 'ufw status' for running firewall):
    ufw route allow in on eth0 comment 'example 1'
    ufw route allow in on eth0 from any port 131,132 to 10.0.0.0/24 proto tcp comment 'example 2'
    ufw route deny in on eth0 from any app OpenSSH to 10.5.0.0/24 comment 'example 3'
    UFW_OUTPUT
  end

  before :each do
    Puppet::Util::ExecutionStub.set do |_command, _options|
      ''
    end
  end

  describe '#get' do
    it 'processes resources' do
      Puppet::Util::ExecutionStub.set do |_command, _options|
        added_routes
      end

      allow(context).to receive(:debug)
      expect(provider.get(context)).to eq [
        {
          name: 'example 1',
          ensure: 'present',
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
        {
          name: 'example 2',
          ensure: 'present',
          action: 'allow',
          interface_in: 'eth0',
          interface_out: nil,
          log: nil,
          from_addr: 'any',
          from_ports_app: '131,132',
          to_addr: '10.0.0.0/24',
          to_ports_app: nil,
          proto: 'tcp',
        },
        {
          name: 'example 3',
          ensure: 'present',
          action: 'deny',
          interface_in: 'eth0',
          interface_out: nil,
          log: nil,
          from_addr: 'any',
          from_ports_app: 'OpenSSH',
          to_addr: '10.5.0.0/24',
          to_ports_app: nil,
          proto: 'any',
        },
      ]
    end

    it 'logs existing lines to debug' do
      Puppet::Util::ExecutionStub.set do |_command, _options|
        added_routes
      end
      expect(context).to receive(:debug).with('Returning list of routes')
      expect(context).to receive(:debug).with("ufw route allow in on eth0 comment 'example 1'")
      expect(context).to receive(:debug).with("ufw route allow in on eth0 from any port 131,132 to 10.0.0.0/24 proto tcp comment 'example 2'")
      expect(context).to receive(:debug).with("ufw route deny in on eth0 from any app OpenSSH to 10.5.0.0/24 comment 'example 3'")

      provider.get(context)
    end
  end

  describe 'create(context, name, should)' do
    it 'creates the resource' do
      executed_commands = []
      Puppet::Util::ExecutionStub.set do |command, _options|
        executed_commands << command
      end

      expect(context).to receive(:notice).with(%r{\ACreating 'a'})

      provider.create(context, 'a', name: 'a', ensure: 'present')

      expect(executed_commands).to eq(['/usr/sbin/ufw route reject from any to any proto any comment \'a\''])
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      executed_commands = []
      Puppet::Util::ExecutionStub.set do |command, _options|
        executed_commands << command
      end
      provider.instance_variable_set(:@instances, [sample_route])

      expect(context).to receive(:notice).with(%r{\AUpdating 'foo'})

      provider.update(context, 'foo', name: 'foo', ensure: 'present', interface_in: 'tun3')

      expect(executed_commands).to eq(
        [
          '/usr/sbin/ufw route delete allow in on tun0 out on eth1 from any to any proto any',
          '/usr/sbin/ufw route allow in on tun3 out on eth1 from any to any proto any comment \'foo\'',
        ],
      )
    end
  end

  describe 'delete(context, name)' do
    it 'deletes the resource' do
      executed_commands = []
      Puppet::Util::ExecutionStub.set do |command, _options|
        executed_commands << command
      end

      provider.instance_variable_set(:@instances, [sample_route])

      expect(context).to receive(:notice).with(%r{\ADeleting 'foo'})

      provider.delete(context, 'foo')

      expect(executed_commands).to eq(['/usr/sbin/ufw route delete allow in on tun0 out on eth1 from any to any proto any'])
    end
  end

  describe 'route_to_hash(context, line)' do
    it 'parses line with basic parameters' do
      expect(provider.route_to_hash(nil, "ufw route allow in on eth0 comment 'test 1'")).to eq(
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

    it 'correctly parses comments with keywords' do
      expect(provider.route_to_hash(nil, "ufw route allow in on eth0 comment 'ufw allow out on eth1 from 10.1.3.3 port 3133 to 10.3.3.3 port 2122'")).to eq(
        {
          ensure: 'present',
          name: 'ufw allow out on eth1 from 10.1.3.3 port 3133 to 10.3.3.3 port 2122',
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

    it 'correctly parses routes with port ranges' do
      expect(provider.route_to_hash(nil, "ufw route allow in on eth0 out on eth2 from 10.1.3.3 port 2020:2030 to 10.3.3.3 port 3030:3040 comment 'test 1'")).to eq(
        {
          ensure: 'present',
          name: 'test 1',
          action: 'allow',
          interface_in: 'eth0',
          interface_out: 'eth2',
          log: nil,
          from_addr: '10.1.3.3',
          from_ports_app: '2020:2030',
          to_addr: '10.3.3.3',
          to_ports_app: '3030:3040',
          proto: 'any',
        },
      )
    end
  end

  describe 'route_to_ufw_params(route)' do
    it 'converts minimal route to string' do
      expect(provider.route_to_ufw_params({ 'action': 'allow' })).to eq('allow from any to any')
    end

    it 'converts full route to string' do
      expect(provider.route_to_ufw_params(
        {
          'action': 'reject',
          'interface_in': 'tun0',
          'interface_out': 'eth0',
          'log': 'log-all',
          'from_addr': '10.1.0.0/24',
          'from_ports_app': '8080,8081',
          'to_addr': '2001:db8:1234::/48',
          'to_ports_app': '3131',
          'proto': 'udp',
        },
      )).to eq('reject in on tun0 out on eth0 log-all from 10.1.0.0/24 port 8080,8081 to 2001:db8:1234::/48 port 3131 proto udp')
    end

    it 'handles any in from_addr' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'from_addr': 'any' })).to eq('allow from any to any')
    end

    it 'handles any in to_addr' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'to_addr': 'any' })).to eq('allow from any to any')
    end

    it 'handles ipv4 address in from_addr' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'from_addr': '10.1.0.0' })).to eq('allow from 10.1.0.0 to any')
    end

    it 'handles ipv4 network in from_addr' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'from_addr': '10.1.0.0/24' })).to eq('allow from 10.1.0.0/24 to any')
    end

    it 'handles ipv6 address in from_addr' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'from_addr': '2606:4700:4700::1111' })).to eq('allow from 2606:4700:4700::1111 to any')
    end

    it 'handles ipv6 network in from_addr' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'from_addr': '2001:db8:1234::/48' })).to eq('allow from 2001:db8:1234::/48 to any')
    end

    it 'handles ipv6 address in from_addr with port' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'from_addr': '2606:4700:4700::1111', 'from_ports_app': 8080 })).to eq('allow from 2606:4700:4700::1111 port 8080 to any')
    end

    it 'handles ipv6 network in from_addr with port' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'from_addr': '2001:db8:1234::/48', 'from_ports_app': 8080 })).to eq('allow from 2001:db8:1234::/48 port 8080 to any')
    end

    it 'handles ipv4 address in to_addr' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'to_addr': '10.1.0.0' })).to eq('allow from any to 10.1.0.0')
    end

    it 'handles ipv4 network in to_addr' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'to_addr': '10.1.0.0/24' })).to eq('allow from any to 10.1.0.0/24')
    end

    it 'handles ipv6 address in to_addr' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'to_addr': '2606:4700:4700::1111' })).to eq('allow from any to 2606:4700:4700::1111')
    end

    it 'handles ipv6 network in to_addr' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'to_addr': '2001:db8:1234::/48' })).to eq('allow from any to 2001:db8:1234::/48')
    end

    it 'handles ipv6 address in to_addr with port' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'to_addr': '2606:4700:4700::1111', 'to_ports_app': 8080 })).to eq('allow from any to 2606:4700:4700::1111 port 8080')
    end

    it 'handles ipv6 network in to_addr with port' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'to_addr': '2001:db8:1234::/48', 'to_ports_app': 8080 })).to eq('allow from any to 2001:db8:1234::/48 port 8080')
    end

    it 'handles ports list in from_ports_app' do
      expect(provider.route_to_ufw_params(
        {
          'action': 'allow',
          'from_addr': '2606:4700:4700::1111',
          'from_ports_app': '8080,8081'
        },
      )).to eq('allow from 2606:4700:4700::1111 port 8080,8081 to any')
    end

    it 'handles ports list in to_ports_app' do
      expect(provider.route_to_ufw_params(
        {
          'action': 'allow',
          'to_addr': '2606:4700:4700::1111',
          'to_ports_app': '8080,8081'
        },
      )).to eq('allow from any to 2606:4700:4700::1111 port 8080,8081')
    end

    it 'handles ports range in from_ports_app' do
      expect(provider.route_to_ufw_params(
        {
          'action': 'allow',
          'from_addr': '2606:4700:4700::1111',
          'from_ports_app': '8080:8090'
        },
      )).to eq('allow from 2606:4700:4700::1111 port 8080:8090 to any')
    end

    it 'handles ports range in to_ports_app' do
      expect(provider.route_to_ufw_params(
        {
          'action': 'allow',
          'to_addr': '2606:4700:4700::1111',
          'to_ports_app': '8080:8090'
        },
      )).to eq('allow from any to 2606:4700:4700::1111 port 8080:8090')
    end

    it 'does not add proto when app is specified in from_ports_app or to_ports_app' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'from_ports_app': 'OpenSSH', 'proto' => 'tcp' })).to eq('allow from any app OpenSSH to any')
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'to_ports_app': 'OpenSSH', 'proto' => 'tcp' })).to eq('allow from any to any app OpenSSH')
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'from_ports_app': 'OpenSSH', 'to_ports_app': 'OpenSSH', 'proto' => 'tcp' })).to eq('allow from any app OpenSSH to any app OpenSSH')
    end

    it 'adds proto if specified without app' do
      expect(provider.route_to_ufw_params({ 'action': 'allow', 'proto': 'tcp' })).to eq('allow from any to any proto tcp')
    end
  end
end
