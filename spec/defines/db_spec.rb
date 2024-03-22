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
      it { is_expected.to contain_file("/etc/dconf/db/#{title}.d").with_ensure('directory') }
      it { is_expected.to contain_file("/etc/dconf/db/#{title}.d/00-default").with_ensure('file') }
      it {
        params['settings'].each do |section, key_vals|
          key_vals.each do |setting, _value|
            is_expected.to contain_ini_setting("db_#{title}_settings_#{section}_#{setting}").with_notify('Exec[dconf_update]')
          end
        end
      }

      context 'with locks' do
        let(:params) do
          super().merge(
            {
              'locks' => [
                'system/proxy/http/host',
                'system/proxy/http/enabled',
              ],
            },
          )
        end

        it { is_expected.to contain_file("/etc/dconf/db/#{title}.d/locks").with_ensure('directory') }
        it { is_expected.to contain_concat("db_#{title}_locks").with_ensure('present') }
        it {
          params['locks'].each do |lock|
            is_expected.to contain_concat__fragment("db_#{title}_locks_#{lock}").with_notify('Exec[dconf_update]')
          end
        }

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
