# frozen_string_literal: true

require 'spec_helper'

describe 'ufw::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'manage_service' => true,
          'service_ensure' => 'running',
          'service_name' => 'ufw',
        }
      end

      it { is_expected.to compile }
    end
  end
end
