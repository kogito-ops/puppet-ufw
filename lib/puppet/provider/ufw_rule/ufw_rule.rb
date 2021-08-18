# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'
require 'puppet/util/execution'
require 'digest'

# Implementation for the ufw_rule type using the Resource API.
class Puppet::Provider::UfwRule::UfwRule < Puppet::ResourceApi::SimpleProvider
  def initialize
    @default_rule_hash = {
      ensure: 'present',
      action: 'reject',
      direction: 'in',
      interface: nil,
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
    context.debug('Returning list of rules')
    return [] unless ufw_installed?

    @instances = []
    rule_list_lines.each do |line|
      context.debug(line)
      hash = rule_to_hash(context, line)
      @instances << hash unless hash.nil?
      context.warning("Could not parse existing rule: #{line}") if hash.nil?
    end
    @instances
  end

  def rule_list_lines
    result = Puppet::Util::Execution.execute(['/usr/sbin/ufw', 'show', 'added'], failonfail: true)
    result.each_line
          .map(&:strip)
          .reject { |line| line.start_with?('ufw route') }
          .reject { |line| line.start_with?('Added user rules') }
  end

  def rule_to_hash(_context, line)
    rule = parse_line_simple_syntax(line)

    return rule unless rule.nil?

    parse_line_full_syntax(line)
  end

  def parse_line_simple_syntax(line)
    %r{\scomment\s'(?<name>[^']+)'} =~ line
    no_comment = line.sub(%r{\scomment\s'(?<name>[^']+)'}, '')

    %r{^ufw (?<action>allow|deny|reject|limit)\s*(?<direction>in|out)*\s*(?<log>log|log-all)*\s*(?<to_ports_app>[\w,:]+)/*(?<proto>\w+)*$} =~ no_comment

    rule = {
      action: action,
      direction: direction,
      log: log,
      to_ports_app: to_ports_app,
      proto: proto,
    }.delete_if { |_k, v| v.nil? }

    return nil if rule.empty?

    rule[:name] = name.nil? ? Digest::SHA256.hexdigest(line) : name

    @default_rule_hash.merge(rule)
  end

  def parse_line_full_syntax(line)
    %r{\scomment\s'(?<name>[^']+)'} =~ line
    no_comment = line.sub(%r{\scomment\s'(?<name>[^']+)'}, '')

    %r{ufw (?<action>allow|deny|reject|limit)\s*(?<direction>in|out)*\s*(on\s(?<interface>[\w\d]+))*\s*(?<log>log|log-all)*} =~ no_comment
    %r{\sfrom\s(?<from_addr>[^\s]+)(\s(port|app)\s(?<from_ports_app>[^\s]+))*} =~ no_comment
    %r{\sto\s(?<to_addr>[^\s]+)(\s(port|app)\s(?<to_ports_app>[^\s]+))*} =~ no_comment
    %r{\sproto\s(?<proto>\w+)} =~ no_comment

    rule = {
      action: action,
      direction: direction,
      interface: interface,
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
    interface_definition = rule[:interface].nil? ? nil : "on #{rule[:interface]}"

    from_addr = rule[:from_addr].nil? ? 'any' : rule[:from_addr]
    from_checked = "#{from_addr}!#{rule[:from_ports_app]}"
    from_definition = case from_checked
                      when %r{.+!$}
                        "from #{from_addr}"
                      when %r{![\d,:]+$}
                        "from #{from_addr} port #{rule[:from_ports_app]}"
                      when %r{!\w+$}
                        "from #{from_addr} app #{rule[:from_ports_app]}"
                      end

    to_addr = rule[:to_addr].nil? ? 'any' : rule[:to_addr]
    to_checked = "#{to_addr}!#{rule[:to_ports_app]}"
    to_definition = case to_checked
                    when %r{.+!$}
                      "to #{to_addr}"
                    when %r{![\d,:]+$}
                      "to #{to_addr} port #{rule[:to_ports_app]}"
                    when %r{!\w+$}
                      "to #{to_addr} app #{rule[:to_ports_app]}"
                    end

    uses_app_name = "#{from_definition} #{to_definition}".include? ' app '

    proto_definition = rule[:proto].nil? ? nil : "proto #{rule[:proto]}"
    proto_definition = nil if uses_app_name # Can't use proto with applications

    comment_definition = rule[:name].nil? ? nil : "comment \'#{rule[:name]}\'"

    [
      rule[:action],
      rule[:direction],
      interface_definition,
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

  def rule_to_ufw_params_nocomment(rule)
    rule_to_ufw_params_array(rule)[0...-1].join(' ')
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    rule = @default_rule_hash.merge(should)
    params = rule_to_ufw_params(rule)

    Puppet::Util::Execution.execute("/usr/sbin/ufw #{params}", failonfail: true)
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    is = @instances.find { |r| r[:name] == name }
    rule = @default_rule_hash.merge(is).merge(should)

    is_params = rule_to_ufw_params_nocomment(is)
    Puppet::Util::Execution.execute("/usr/sbin/ufw delete #{is_params}", failonfail: true)

    params = rule_to_ufw_params(rule)
    Puppet::Util::Execution.execute("/usr/sbin/ufw #{params}", failonfail: true)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")

    is = @instances.find { |r| r[:name] == name }
    params = rule_to_ufw_params_nocomment(is)
    Puppet::Util::Execution.execute("/usr/sbin/ufw delete #{params}", failonfail: true)
  end

  def ufw_installed?
    File.file?('/usr/sbin/ufw')
  end
end
