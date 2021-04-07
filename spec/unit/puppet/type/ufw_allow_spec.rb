# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/ufw_allow'

RSpec.describe 'the ufw_allow type' do
  it 'loads' do
    expect(Puppet::Type.type(:ufw_allow)).not_to be_nil
  end
end
