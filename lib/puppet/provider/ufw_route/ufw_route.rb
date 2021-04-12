# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Implementation for the ufw_route type using the Resource API.
class Puppet::Provider::UfwRoute::UfwRoute < Puppet::ResourceApi::SimpleProvider
  def initialize
    @default_rule_hash = {
      ensure: 'present',
      action: 'reject',
      interface_in: nil,
      interface_out: nil,
      log: nil,
      from_addr: 'any',
      from_ports_app: nil,
      to_addr: 'any',
      to_ports_app: nil,
      proto: 'any',
    }
    @instances = []
    super()
  end

  def get(context)
    context.debug('Returning list of routes')

    @instances = []
    rule_list_lines.each do |line|
      context.debug(line)
      hash = rule_to_hash(context, line)
      @instances << hash unless hash.nil?
      context.warning("Could not parse existing route: #{line}") if hash.nil?
    end
    @instances
  end

  def rule_list_lines
    result = Puppet::Util::Execution.execute(['/usr/sbin/ufw', 'show', 'added'], failonfail: true)
    result.each_line
          .map(&:strip)
          .select { |line| line.start_with?('ufw route') }
  end

  def rule_to_hash(_context, line)
    %r{\scomment\s'(?<name>[^']+)'} =~ line
    no_comment = line.sub(%r{\scomment\s'(?<name>[^']+)'}, '')

    %r{ufw route (?<action>allow|deny|reject|limit)\s*(in on (?<interface_in>\w+))*\s*(out on (?<interface_out>\w+))*\s*(?<log>log|log-all)*} =~ no_comment
    %r{\sfrom\s(?<from_addr>[^\s]+)(\s(port|app)\s(?<from_ports_app>[^\s]+))*} =~ no_comment
    %r{\sto\s(?<to_addr>[^\s]+)(\s(port|app)\s(?<to_ports_app>[^\s]+))*} =~ no_comment
    %r{\sproto\s(?<proto>\w+)} =~ no_comment

    rule = {
      action: action,
      interface_in: interface_in,
      interface_out: interface_out,
      log: log,
      from_addr: from_addr,
      from_ports_app: from_ports_app,
      to_addr: to_addr,
      to_ports_app: to_ports_app,
      proto: proto,
    }.delete_if { |_k, v| v.nil? }

    return nil if rule.empty?

    rule[:name] = name.nil? ? Digest::SHA256.hexdigest(no_comment) : name

    @default_rule_hash.merge(rule)
  end

  def rule_to_ufw_params_array(rule)
    in_definition = rule[:interface_in].nil? ? nil : "in on #{rule[:interface_in]}"
    out_definition = rule[:interface_out].nil? ? nil : "out on #{rule[:interface_out]}"

    from_addr = rule[:from_addr].nil? ? 'any' : rule[:from_addr]
    from_checked = "#{from_addr}:#{rule[:from_ports_app]}"
    from_definition = case from_checked
                      when %r{.+:$}
                        "from #{from_addr}"
                      when %r{:\d+$}
                        "from #{from_addr} port #{rule[:from_ports_app]}"
                      when %r{:\w+$}
                        "from #{from_addr} app #{rule[:from_ports_app]}"
                      end

    to_addr = rule[:to_addr].nil? ? 'any' : rule[:to_addr]
    to_checked = "#{to_addr}:#{rule[:to_ports_app]}"
    to_definition = case to_checked
                    when %r{.+:$}
                      "to #{to_addr}"
                    when %r{:\d+$}
                      "to #{to_addr} port #{rule[:to_ports_app]}"
                    when %r{:\w+$}
                      "to #{to_addr} app #{rule[:to_ports_app]}"
                    end

    uses_app_name = "#{from_definition} #{to_definition}".include? ' app '

    proto_definition = rule[:proto].nil? ? nil : "proto #{rule[:proto]}"
    proto_definition = nil if uses_app_name # Can't use proto with applications

    comment_definition = rule[:name].nil? ? nil : "comment \'#{rule[:name]}\'"

    [
      rule[:action],
      in_definition,
      out_definition,
      rule[:log],
      from_definition,
      to_definition,
      proto_definition,
      comment_definition,
    ].compact
  end

  def rule_to_ufw_params(rule)
    rule_to_ufw_params_array(rule).join(' ')
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    rule = @default_rule_hash.merge(should)
    params = rule_to_ufw_params(rule)

    Puppet::Util::Execution.execute("/usr/sbin/ufw route #{params}", failonfail: true)
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    is = @instances.find { |r| r[:name] == name }
    rule = @default_rule_hash.merge(is).merge(should)

    is_params = rule_to_ufw_params(is)
    Puppet::Util::Execution.execute("/usr/sbin/ufw route delete #{is_params}", failonfail: true)

    params = rule_to_ufw_params(rule)
    Puppet::Util::Execution.execute("/usr/sbin/ufw route #{params}", failonfail: true)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")

    is = @instances.find { |r| r[:name] == name }
    params = rule_to_ufw_params(is)
    Puppet::Util::Execution.execute("/usr/sbin/ufw route delete #{params}", failonfail: true)
  end
end
