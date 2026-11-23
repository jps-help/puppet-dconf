# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'dconf' do
  context 'with a profile and a db' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<~PUPPET
          include dconf

          dconf::profile { 'user':
            entries => {
              'user'  => { 'type' => 'user', 'order' => 10 },
              'local' => { 'type' => 'system', 'order' => 21 },
            },
          }

          dconf::db { 'local':
            settings => {
              'system/proxy/http' => {
                'host'    => "'172.16.0.1'",
                'enabled' => 'true',
              },
            },
            locks    => [
              '/system/proxy/http/host',
              '/system/proxy/http/enabled',
            ],
          }
        PUPPET
      end
    end

    describe package(fact('os.family') == 'Debian' ? 'dconf-cli' : 'dconf') do
      it { is_expected.to be_installed }
    end

    describe file('/etc/dconf/profile/user') do
      its(:content) { is_expected.to match(%r{^user-db:user\nsystem-db:local$}) }
    end

    describe file('/etc/dconf/db/local.d/locks/00-local_default') do
      its(:content) { is_expected.to match(%r{^/system/proxy/http/host$}) }
    end

    describe file('/etc/dconf/db/local') do
      it { is_expected.to be_file }
    end

    describe command('DCONF_PROFILE=user dconf read /system/proxy/http/host') do
      its(:stdout) { is_expected.to eq("'172.16.0.1'\n") }
    end
  end
end
