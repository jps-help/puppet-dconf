# frozen_string_literal: true

require 'spec_helper'

describe 'dconf::db' do
  let(:title) { 'example' }
  let(:pre_condition) { 'include dconf' }
  let(:params) do
    {
      'settings' => {
        'system/proxy/http' => {
          'host' => "'172.16.0.1'",
          'enabled' => 'true',
        },
      },
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_file("/etc/dconf/db")}
      it { is_expected.to contain_file("/etc/dconf/db/#{title}.d").with_ensure('directory') }
      it { is_expected.to contain_dconf__cfg_file("#{title}_default")}
      it { is_expected.to contain_file("/etc/dconf/db/#{title}.d/00-#{title}_default")}

      context 'with locks' do
        let(:params) do
          super().merge(
            {
              'locks' => [
                '/system/proxy/http/host',
                '/system/proxy/http/enabled',
              ],
            },
          )
        end

        it { is_expected.to contain_file("/etc/dconf/db/#{title}.d/locks").with_ensure('directory') }
        it { is_expected.to contain_dconf__locks_file("#{title}_default")}
        it { is_expected.to contain_file("/etc/dconf/db/#{title}.d/locks/00-#{title}_default") }

        context 'with purge' do
          let(:params) do
            super().merge(
              {
                'purge' => true,
              },
            )
          end

          it { is_expected.to contain_file("/etc/dconf/db/#{title}.d").with_purge(true) }
          it { is_expected.to contain_file("/etc/dconf/db/#{title}.d/locks").with_purge(true) }
        end
      end
    end
  end
end
