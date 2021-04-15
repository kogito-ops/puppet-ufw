# frozen_string_literal: true

require 'spec_helper'

describe 'ufw' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it do
        is_expected.to compile.with_all_deps
        is_expected.to contain_class('ufw::install').that_comes_before('Class[ufw::config]')
        is_expected.to contain_class('ufw::config').that_comes_before('Class[ufw::service]')
        is_expected.to contain_class('ufw::install').that_comes_before('Class[ufw::service]')
      end

      context 'with purge_unmanaged_routes => true' do
        let(:params) { { purge_unmanaged_routes: true } }

        it 'creates resource purge for routes' do
          is_expected.to contain_resources('ufw_route').only_with_purge(true)
        end
      end

      context 'with purge_unmanaged_routes => false' do
        let(:params) { { purge_unmanaged_routes: false } }

        it 'does not create resource purge for routes' do
          is_expected.not_to contain_resources('ufw_route').only_with_purge(true)
        end
      end

      context 'with purge_unmanaged_rules => true' do
        let(:params) { { purge_unmanaged_rules: true } }

        it 'creates resource purge for rules' do
          is_expected.to contain_resources('ufw_rule').only_with_purge(true)
        end
      end

      context 'with purge_unmanaged_rules => false' do
        let(:params) { { purge_unmanaged_rules: false } }

        it 'does not create resource purge for rules' do
          is_expected.not_to contain_resources('ufw_rule').only_with_purge(true)
        end
      end
    end
  end
end
