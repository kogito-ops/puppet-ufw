# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/ufw_route'

RSpec.describe 'the ufw_route type' do
  it 'loads' do
    expect(Puppet::Type.type(:ufw_route)).not_to be_nil
  end
end
