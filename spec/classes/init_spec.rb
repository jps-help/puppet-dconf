# frozen_string_literal: true

require 'spec_helper'

describe 'dconf' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }
      case os_facts[:osfamily]
      when 'Debian'
        it { is_expected.to contain_package('dconf-cli').with_ensure('installed') }
      when 'RedHat'
        it { is_expected.to contain_package('dconf').with_ensure('installed') }
      end
    end
  end
end
