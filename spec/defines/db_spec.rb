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
      it { is_expected.to contain_file("/etc/dconf/db/#{title}.d/00-default").with_ensure('file').with_content(%r{[system/proxy/http]}) }
      it { is_expected.to contain_file("/etc/dconf/db/#{title}.d/00-default").with_ensure('file').with_content(%r{host = '172.16.0.1'}) }
      it { is_expected.to contain_file("/etc/dconf/db/#{title}.d/00-default").with_ensure('file').with_content(%r{enabled = true}) }

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
        it { is_expected.to contain_file("db_#{title}_locks").with_ensure('present').with_content(%r{/system/proxy/http/host\n/system/proxy/http/enabled}) }

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
