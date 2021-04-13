# frozen_string_literal: true

require 'spec_helper'

ensure_module_defined('Puppet::Provider::UfwRule')
require 'puppet/provider/ufw_rule/ufw_rule'

RSpec.describe Puppet::Provider::UfwRule::UfwRule do
  subject(:provider) { described_class.new }

  let(:context) { instance_double('Puppet::ResourceApi::BaseContext', 'context') }

  # let(:added_rules) do
  #   <<-UFW_OUTPUT

  #   UFW_OUTPUT
  # end

  let(:added_rules_simple_syntax) do
    <<-UFW_OUTPUT
    Added user rules (see 'ufw status' for running firewall):
    ufw allow 3133 comment 'port only'
    ufw deny 8080/tcp comment 'port with proto'
    ufw allow out 80,443/tcp comment 'list of ports with proto'
    ufw allow log 555,777/tcp comment 'list of ports with log option and proto'
    ufw allow out log-all 1111 comment 'log-all with port without proto'
    UFW_OUTPUT
  end

  let(:added_rules_full_syntax) do
    <<-UFW_OUTPUT
    Added user rules (see 'ufw status' for running firewall):
    ufw allow out on eth1 log from any port 555,777 to any port 555,777 proto tcp comment 'full example with any'
    ufw allow in on eth1 from 2001:db8:1234::/48 port 3133 to 2001:db8:1234::/48 port 2122 comment 'full example ipv6'
    ufw allow to any proto gre comment 'full example proto gre'
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

  before :each do
    Puppet::Util::ExecutionStub.set do |command, _options|
      added_rules_full if command == ['/usr/sbin/ufw', 'show', 'added']
    end
  end

  describe '#get' do
    it 'processes simple syntax' do
      Puppet::Util::ExecutionStub.set do |_command, _options|
        added_rules_simple_syntax
      end
      allow(context).to receive(:debug)

      expect(provider.get(context)).to eq [
        {
          # ufw allow 3133 comment 'port only'
          ensure: 'present',
          name: 'port only',
          action: 'allow',
          direction: 'in',
          interface: nil,
          log: nil,
          from_addr: 'any',
          from_ports_app: nil,
          to_addr: 'any',
          to_ports_app: '3133',
          proto: 'any',
        },
        {
          # ufw deny 8080/tcp comment 'port with proto'
          ensure: 'present',
          name: 'port with proto',
          action: 'deny',
          direction: 'in',
          interface: nil,
          log: nil,
          from_addr: 'any',
          from_ports_app: nil,
          to_addr: 'any',
          to_ports_app: '8080',
          proto: 'tcp',
        },
        {
          # ufw allow out 80,443/tcp comment 'list of ports with proto'
          ensure: 'present',
          name: 'list of ports with proto',
          action: 'allow',
          direction: 'out',
          interface: nil,
          log: nil,
          from_addr: 'any',
          from_ports_app: nil,
          to_addr: 'any',
          to_ports_app: '80,443',
          proto: 'tcp',
        },
        {
          # ufw allow log 555,777/tcp comment 'list of ports with log option and proto'
          ensure: 'present',
          name: 'list of ports with log option and proto',
          action: 'allow',
          direction: 'in',
          interface: nil,
          log: 'log',
          from_addr: 'any',
          from_ports_app: nil,
          to_addr: 'any',
          to_ports_app: '555,777',
          proto: 'tcp',
        },
        {
          # ufw allow out log-all 1111 comment 'log-all with port without proto'
          ensure: 'present',
          name: 'log-all with port without proto',
          action: 'allow',
          direction: 'out',
          interface: nil,
          log: 'log-all',
          from_addr: 'any',
          from_ports_app: nil,
          to_addr: 'any',
          to_ports_app: '1111',
          proto: 'any',
        },
      ]
    end

    it 'processes full syntax' do
      Puppet::Util::ExecutionStub.set do |_command, _options|
        added_rules_full_syntax
      end
      allow(context).to receive(:debug)

      expect(provider.get(context)).to eq [
        {
          # ufw allow out on eth1 log from any port 555,777 to any port 555,777 proto tcp comment 'full example with any'
          ensure: 'present',
          name: 'full example with any',
          action: 'allow',
          direction: 'out',
          interface: 'eth1',
          log: 'log',
          from_addr: 'any',
          from_ports_app: '555,777',
          to_addr: 'any',
          to_ports_app: '555,777',
          proto: 'tcp',
        },
        {
          # ufw allow in on eth1 from 2001:db8:1234::/48 port 3133 to 2001:db8:1234::/48 port 2122 comment 'full example ipv6'
          ensure: 'present',
          name: 'full example ipv6',
          action: 'allow',
          direction: 'in',
          interface: 'eth1',
          log: nil,
          from_addr: '2001:db8:1234::/48',
          from_ports_app: '3133',
          to_addr: '2001:db8:1234::/48',
          to_ports_app: '2122',
          proto: 'any',
        },
        {
          # ufw allow to any proto gre comment 'full example proto gre'
          ensure: 'present',
          name: 'full example proto gre',
          action: 'allow',
          direction: 'in',
          interface: nil,
          log: nil,
          from_addr: 'any',
          from_ports_app: nil,
          to_addr: 'any',
          to_ports_app: nil,
          proto: 'gre',
        },
      ]
    end

    it 'logs existing lines to debug' do
      Puppet::Util::ExecutionStub.set do |_command, _options|
        <<-UFW_OUTPUT
        Added user rules (see 'ufw status' for running firewall):
        ufw allow 3133 comment 'simple'
        ufw reject to any proto gre comment 'full'
        UFW_OUTPUT
      end
      expect(context).to receive(:debug).with('Returning list of rules')
      expect(context).to receive(:debug).with("ufw allow 3133 comment 'simple'")
      expect(context).to receive(:debug).with("ufw reject to any proto gre comment 'full'")

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

      expect(executed_commands).to eq(["/usr/sbin/ufw reject in from any to any proto any comment 'a'"])
    end
  end

  describe 'update(context, name, should)' do
    it 'updates the resource' do
      executed_commands = []
      Puppet::Util::ExecutionStub.set do |command, _options|
        executed_commands << command
      end
      provider.instance_variable_set(:@instances, [sample_rule])

      expect(context).to receive(:notice).with(%r{\AUpdating 'foo'})

      provider.update(context, 'foo', name: 'foo', ensure: 'present', 'interface': 'tun0')

      expect(executed_commands).to eq(
        [
          '/usr/sbin/ufw delete allow in from any to any proto any comment \'foo\'',
          '/usr/sbin/ufw allow in on tun0 from any to any proto any comment \'foo\'',
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

      provider.instance_variable_set(:@instances, [sample_rule])

      expect(context).to receive(:notice).with(%r{\ADeleting 'foo'})

      provider.delete(context, 'foo')

      expect(executed_commands).to eq(['/usr/sbin/ufw delete allow in from any to any proto any comment \'foo\''])
    end
  end

  describe 'rule_to_hash(context, line)' do
    it 'parses line in full syntax' do
      expect(provider.rule_to_hash(nil, "ufw allow from 10.5.3.0/24 proto gre comment 'test 1'")).to eq(
        {
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
        },
      )
    end

    it 'parses line in short syntax' do
      expect(provider.rule_to_hash(nil, "ufw allow log 555,777/tcp comment 'test 1'")).to eq(
        {
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
        },
      )
    end

    it 'correctly parses comments with keywords in full syntax' do
      expect(provider.rule_to_hash(nil, "ufw allow from 10.5.3.0/24 proto gre comment 'ufw allow out on eth1 from 10.1.3.3 port 3133 to 10.3.3.3 port 2122'")).to eq(
        {
          ensure: 'present',
          name: 'ufw allow out on eth1 from 10.1.3.3 port 3133 to 10.3.3.3 port 2122',
          action: 'allow',
          direction: 'in',
          interface: nil,
          log: nil,
          from_addr: '10.5.3.0/24',
          from_ports_app: nil,
          to_addr: 'any',
          to_ports_app: nil,
          proto: 'gre',
        },
      )
    end

    it 'correctly parses comments with keywords in short syntax' do
      expect(provider.rule_to_hash(nil, "ufw allow log 555,777/tcp comment 'ufw allow log 555,777/tcp comment'")).to eq(
        {
          ensure: 'present',
          name: 'ufw allow log 555,777/tcp comment',
          action: 'allow',
          direction: 'in',
          interface: nil,
          log: 'log',
          from_addr: 'any',
          from_ports_app: nil,
          to_addr: 'any',
          to_ports_app: '555,777',
          proto: 'tcp',
        },
      )
    end
  end

  describe 'rule_to_ufw_params(rule)' do
    it 'converts minimal rule to string' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow' })).to eq('allow from any to any')
    end

    it 'converts full rule to string' do
      expect(provider.rule_to_ufw_params(
        {
          'action': 'reject',
          'direction': 'in',
          'interface': 'eth0',
          'log': 'log-all',
          'from_addr': '10.1.0.0/24',
          'from_ports_app': '8080,8081',
          'to_addr': '2001:db8:1234::/48',
          'to_ports_app': '3131',
          'proto': 'udp',
        },
      )).to eq('reject in on eth0 log-all from 10.1.0.0/24 port 8080,8081 to 2001:db8:1234::/48 port 3131 proto udp')
    end

    it 'handles any in from_addr' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'from_addr': 'any' })).to eq('allow from any to any')
    end

    it 'handles any in to_addr' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'to_addr': 'any' })).to eq('allow from any to any')
    end

    it 'handles ipv4 address in from_addr' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'from_addr': '10.1.0.0' })).to eq('allow from 10.1.0.0 to any')
    end

    it 'handles ipv4 network in from_addr' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'from_addr': '10.1.0.0/24' })).to eq('allow from 10.1.0.0/24 to any')
    end

    it 'handles ipv6 address in from_addr' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'from_addr': '2606:4700:4700::1111' })).to eq('allow from 2606:4700:4700::1111 to any')
    end

    it 'handles ipv6 network in from_addr' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'from_addr': '2001:db8:1234::/48' })).to eq('allow from 2001:db8:1234::/48 to any')
    end

    it 'handles ipv6 address in from_addr with port' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'from_addr': '2606:4700:4700::1111', 'from_ports_app': 8080 })).to eq('allow from 2606:4700:4700::1111 port 8080 to any')
    end

    it 'handles ipv6 network in from_addr with port' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'from_addr': '2001:db8:1234::/48', 'from_ports_app': 8080 })).to eq('allow from 2001:db8:1234::/48 port 8080 to any')
    end

    it 'handles ipv4 address in to_addr' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'to_addr': '10.1.0.0' })).to eq('allow from any to 10.1.0.0')
    end

    it 'handles ipv4 network in to_addr' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'to_addr': '10.1.0.0/24' })).to eq('allow from any to 10.1.0.0/24')
    end

    it 'handles ipv6 address in to_addr' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'to_addr': '2606:4700:4700::1111' })).to eq('allow from any to 2606:4700:4700::1111')
    end

    it 'handles ipv6 network in to_addr' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'to_addr': '2001:db8:1234::/48' })).to eq('allow from any to 2001:db8:1234::/48')
    end

    it 'handles ipv6 address in to_addr with port' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'to_addr': '2606:4700:4700::1111', 'to_ports_app': 8080 })).to eq('allow from any to 2606:4700:4700::1111 port 8080')
    end

    it 'handles ipv6 network in to_addr with port' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'to_addr': '2001:db8:1234::/48', 'to_ports_app': 8080 })).to eq('allow from any to 2001:db8:1234::/48 port 8080')
    end

    it 'handles comma separated ports in from_ports_app' do
      expect(provider.rule_to_ufw_params(
        {
          'action': 'allow',
          'from_addr': '2606:4700:4700::1111',
          'from_ports_app': '8080,8081'
        },
      )).to eq('allow from 2606:4700:4700::1111 port 8080,8081 to any')
    end

    it 'handles comma separated ports in to_ports_app' do
      expect(provider.rule_to_ufw_params(
        {
          'action': 'allow',
          'to_addr': '2606:4700:4700::1111',
          'to_ports_app': '8080,8081'
        },
      )).to eq('allow from any to 2606:4700:4700::1111 port 8080,8081')
    end

    it 'does not add proto when app is specified in from_ports_app or to_ports_app' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'from_ports_app': 'OpenSSH', 'proto' => 'tcp' })).to eq('allow from any app OpenSSH to any')
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'to_ports_app': 'OpenSSH', 'proto' => 'tcp' })).to eq('allow from any to any app OpenSSH')
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'from_ports_app': 'OpenSSH', 'to_ports_app': 'OpenSSH', 'proto' => 'tcp' })).to eq('allow from any app OpenSSH to any app OpenSSH')
    end

    it 'adds proto if specified without app' do
      expect(provider.rule_to_ufw_params({ 'action': 'allow', 'proto': 'tcp' })).to eq('allow from any to any proto tcp')
    end
  end
end
