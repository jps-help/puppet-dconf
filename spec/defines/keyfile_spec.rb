# frozen_string_literal: true

require 'spec_helper'

describe 'dconf::keyfile' do
  let(:title) { 'example' }
  let(:pre_condition) {
    # Simulate the directory existing
    "file { '/etc/dconf/db/local.d': ensure => 'directory' }"
  }
  let(:params) do
    {
      'ensure' => 'present',
      'parent_db' => '/etc/dconf/db/local.d',
      'priority' => '75',
      'settings' => {
        'system/proxy/http' => {
          'host' => "'172.16.0.1'",
          'enabled' => 'true',
        },
      },
    }
  end

  let(:pre_condition) do
    # Simulate the directory existing
    "file { '/etc/dconf/db/local.d': ensure => 'directory' }"
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_file("#{params['parent_db']}/#{params['priority']}-#{title}").with_content(%r{[system/proxy/http]}) }
      it { is_expected.to contain_file("#{params['parent_db']}/#{params['priority']}-#{title}").with_content(%r{host = '172.16.0.1'}) }
      it { is_expected.to contain_file("#{params['parent_db']}/#{params['priority']}-#{title}").with_content(%r{enabled = true}) }
      it { is_expected.to contain_exec('dconf_update').with_refreshonly(true)}
      it { is_expected.to contain_file("#{params['parent_db']}/#{params['priority']}-#{title}").that_notifies('Exec[dconf_update]') }
    end
  end
end
