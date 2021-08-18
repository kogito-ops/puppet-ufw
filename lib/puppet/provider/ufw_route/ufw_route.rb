# frozen_string_literal: true

require 'puppet/resource_api/simple_provider'

# Implementation for the ufw_route type using the Resource API.
class Puppet::Provider::UfwRoute::UfwRoute < Puppet::ResourceApi::SimpleProvider
  def initialize
    @default_route_hash = {
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
    return [] unless ufw_installed?

    @instances = []
    route_list_lines.each do |line|
      context.debug(line)
      hash = route_to_hash(context, line)
      @instances << hash unless hash.nil?
      context.warning("Could not parse existing route: #{line}") if hash.nil?
    end
    @instances
  end

  def route_list_lines
    result = Puppet::Util::Execution.execute(['/usr/sbin/ufw', 'show', 'added'], failonfail: true)
    result.each_line
          .map(&:strip)
          .select { |line| line.start_with?('ufw route') }
  end

  def route_to_hash(_context, line)
    %r{\scomment\s'(?<name>[^']+)'} =~ line
    no_comment = line.sub(%r{\scomment\s'(?<name>[^']+)'}, '')

    %r{ufw route (?<action>allow|deny|reject|limit)\s*(in on (?<interface_in>\w+))*\s*(out on (?<interface_out>\w+))*\s*(?<log>log|log-all)*} =~ no_comment
    %r{\sfrom\s(?<from_addr>[^\s]+)(\s(port|app)\s(?<from_ports_app>[^\s]+))*} =~ no_comment
    %r{\sto\s(?<to_addr>[^\s]+)(\s(port|app)\s(?<to_ports_app>[^\s]+))*} =~ no_comment
    %r{\sproto\s(?<proto>\w+)} =~ no_comment

    route = {
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

    return nil if route.empty?

    route[:name] = name.nil? ? Digest::SHA256.hexdigest(no_comment) : name

    @default_route_hash.merge(route)
  end

  def route_to_ufw_params_array(route)
    in_definition = route[:interface_in].nil? ? nil : "in on #{route[:interface_in]}"
    out_definition = route[:interface_out].nil? ? nil : "out on #{route[:interface_out]}"

    from_addr = route[:from_addr].nil? ? 'any' : route[:from_addr]
    from_checked = "#{from_addr}!#{route[:from_ports_app]}"
    from_definition = case from_checked
                      when %r{.+!$}
                        "from #{from_addr}"
                      when %r{![\d,:]+$}
                        "from #{from_addr} port #{route[:from_ports_app]}"
                      when %r{!\w+$}
                        "from #{from_addr} app #{route[:from_ports_app]}"
                      end

    to_addr = route[:to_addr].nil? ? 'any' : route[:to_addr]
    to_checked = "#{to_addr}!#{route[:to_ports_app]}"
    to_definition = case to_checked
                    when %r{.+!$}
                      "to #{to_addr}"
                    when %r{![\d,:]+$}
                      "to #{to_addr} port #{route[:to_ports_app]}"
                    when %r{!\w+$}
                      "to #{to_addr} app #{route[:to_ports_app]}"
                    end

    uses_app_name = "#{from_definition} #{to_definition}".include? ' app '

    proto_definition = route[:proto].nil? ? nil : "proto #{route[:proto]}"
    proto_definition = nil if uses_app_name # Can't use proto with applications

    comment_definition = route[:name].nil? ? nil : "comment \'#{route[:name]}\'"

    [
      route[:action],
      in_definition,
      out_definition,
      route[:log],
      from_definition,
      to_definition,
      proto_definition,
      comment_definition,
    ].compact
  end

  def route_to_ufw_params(route)
    route_to_ufw_params_array(route).join(' ')
  end

  def rule_to_ufw_params_nocomment(rule)
    route_to_ufw_params_array(rule)[0...-1].join(' ')
  end

  def create(context, name, should)
    context.notice("Creating '#{name}' with #{should.inspect}")
    route = @default_route_hash.merge(should)
    params = route_to_ufw_params(route)

    Puppet::Util::Execution.execute("/usr/sbin/ufw route #{params}", failonfail: true)
  end

  def update(context, name, should)
    context.notice("Updating '#{name}' with #{should.inspect}")
    is = @instances.find { |r| r[:name] == name }
    route = @default_route_hash.merge(is).merge(should)

    is_params = rule_to_ufw_params_nocomment(is)
    Puppet::Util::Execution.execute("/usr/sbin/ufw route delete #{is_params}", failonfail: true)

    params = route_to_ufw_params(route)
    Puppet::Util::Execution.execute("/usr/sbin/ufw route #{params}", failonfail: true)
  end

  def delete(context, name)
    context.notice("Deleting '#{name}'")

    is = @instances.find { |r| r[:name] == name }
    params = rule_to_ufw_params_nocomment(is)
    Puppet::Util::Execution.execute("/usr/sbin/ufw route delete #{params}", failonfail: true)
  end

  def ufw_installed?
    File.file?('/usr/sbin/ufw')
  end
end
