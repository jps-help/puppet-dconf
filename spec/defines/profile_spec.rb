# frozen_string_literal: true

require 'spec_helper'

describe 'dconf::profile' do
  let(:title) { 'namevar' }
  let(:pre_condition) { 'include dconf' }
  let(:params) do
    {}
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:title) { 'example' }
      let(:facts) { os_facts }

      context 'without entries' do
        it { is_expected.to raise_error(Puppet::Error) }
      end
      context 'with simple config' do
        let(:params)do
          super().merge(
            {
              'entries' => {
                'user' => {
                  'type'  => 'user',
                  'order' => 10,
                 },
                'local' => {
                  'type'  => 'system',
                  'order' => 21,
                },
                'site' => {
                  'type'  => 'system',
                  'order' => 21,
                },
              },              
            },
          )
        end
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_concat("profile_#{title}").with_ensure('present') }
        
        context 'profile entries' do
          it {
            params['entries'].each do |db_name, attrs|
              is_expected.to contain_concat__fragment("profile_#{title}_#{db_name}")
            end
          }
        end
      end
    end
  end
end
