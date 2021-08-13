# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ufw_route',
  docs: <<-EOS,
@summary a ufw_route type controls routing rules
@example
  ufw_route { 'route vpn traffic to internal net':
    ensure         => 'present',
    action         => 'allow',
    interface_in   => 'tun0',
    interface_out  => 'eth0',
    log            => 'log',
    from_addr      => 'any',
    from_ports_app => undef,
    to_addr        => '10.5.0.0/24',
    to_ports_app   => undef,
    proto          => 'any',
  }

This type provides Puppet with the capabilities to manage ufw routing rules.

**Important**: The default action is `reject`, so traffic would be rejected
if `action` parameter is omitted.

**Autorequires**:
* `Class[ufw::install]`
EOS
  features: [],
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether this resource should be present or absent on the target system.',
      default: 'present',
    },
    action: {
      type: 'Enum[allow, deny, reject, limit]',
      desc: 'Action to perform. default: reject',
      default: 'reject',
    },
    interface_in: {
      type: 'Optional[String]',
      desc: 'Interface that recieves traffic.',
    },
    interface_out: {
      type: 'Optional[String]',
      desc: 'Interface that sends traffic.',
    },
    log: {
      type: 'Optional[Enum[log, log-all]]',
      desc: 'Logging option.',
    },
    from_addr: {
      type: 'Optional[String]',
      desc: 'Source address. default: any',
      default: 'any',
    },
    from_ports_app: {
      type: 'Optional[Variant[Integer, String]]',
      desc: 'Source address ports or app.',
    },
    to_addr: {
      type: 'Optional[String]',
      desc: 'Destination address. default: any',
      default: 'any',
    },
    to_ports_app: {
      type: 'Optional[Variant[Integer, String]]',
      desc: 'Destination address ports or app.',
    },
    proto: {
      type: 'Optional[String]',
      desc: 'Protocol. default: any',
      default: 'any',
    },
    name: {
      type: 'String',
      desc: 'The name of the resource you want to manage.',
      behaviour: :namevar,
    },
  },
  autorequire: {
    class: 'ufw::install',
  },
)
