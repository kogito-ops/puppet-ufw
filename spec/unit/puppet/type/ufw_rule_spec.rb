# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/ufw_rule'

RSpec.describe 'the ufw_rule type' do
  it 'loads' do
    expect(Puppet::Type.type(:ufw_rule)).not_to be_nil
  end
end
