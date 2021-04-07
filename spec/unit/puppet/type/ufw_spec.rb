# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/ufw'

RSpec.describe 'the ufw type' do
  it 'loads' do
    expect(Puppet::Type.type(:ufw)).not_to be_nil
  end
end
