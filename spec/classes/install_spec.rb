# frozen_string_literal: true

require 'spec_helper'

describe 'ufw::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'manage_package' => true,
          'package_name' => 'ufw',
          'packege_ensure' => 'present',
        }
      end

      it { is_expected.to compile }
    end
  end
end
