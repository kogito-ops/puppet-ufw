# frozen_string_literal: true

require 'spec_helper'

describe 'ufw' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to compile.with_all_deps
        is_expected.to contain_class('ufw::install').that_comes_before('Class[ufw::service]')
      end
    end
  end
end
