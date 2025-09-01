# frozen_string_literal: true

require 'spec_helper'

describe 'dconf::db_locks' do
  let(:title) { 'example' }
  let(:pre_condition) do
    # Simulate the directory existing
    "file { '/etc/dconf/db/local.d': ensure => 'directory' }
   file { '/etc/dconf/db/local.d/locks': ensure => 'directory' }"
  end
  let(:params) do
    {
      'ensure' => 'present',
      'parent_db' => '/etc/dconf/db/local.d',
      'priority' => '75',
      'locks' => [
        '/system/proxy/http/host',
        '/system/proxy/http/enabled',
      ],
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_file("#{params['parent_db']}/locks/#{params['priority']}-#{title}").with_ensure('present').with_content(%r{/system/proxy/http/host\n/system/proxy/http/enabled}) }
      it { is_expected.to contain_exec('dconf_update').with_refreshonly(true) }
      it { is_expected.to contain_file("#{params['parent_db']}/locks/#{params['priority']}-#{title}").that_notifies('Exec[dconf_update]') }
    end
  end
end
