# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'ufw_rule',
  docs: <<-EOS,
@summary a ufw_rule type controls regular rules
@example
  ufw_rule { 'allow ssh from internal networks':
    ensure         => 'present',
    action         => 'allow',
    direction      => 'in',
    interface      => undef,
    log            => undef,
    from_addr      => '10.1.3.0/24',
    from_ports_app => 'any',
    to_addr        => '10.3.0.1',
    to_ports_app   => 22,
    proto          => 'tcp',
  }

This type provides Puppet with the capabilities to manage regular ufw rules.

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
    direction: {
      type: "Enum['in', 'out']", # "in" is too short, puppet can't parse it without quotes
      desc: 'Traffic direction. default: in',
      default: 'in',
    },
    interface: {
      type: 'Optional[String]',
      desc: 'Interface that recieves traffic.',
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
