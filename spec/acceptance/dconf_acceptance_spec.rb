require 'spec_helper_acceptance'

describe 'dconf' do
  it 'works idempotently with no errors' do
    dconf_init = <<-PUPPET
    include dconf
    PUPPET
    # Example dconf profile
    dconf_profile = <<-PUPPET
    dconf::profile { 'user':
      entries => {
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
          'order' => 22,
        },
      },
    }
    PUPPET
    # Example dconf DB settings
    dconf_db = <<-PUPPET
    dconf::db { 'local':
      settings => {
        'system/proxy/http' => {
          'host' => '172.16.0.1',
          'enabled' => 'true',
        },
      locks => [
        '/system/proxy/http/host',
        '/system/proxy/http/enabled',
      ],
    }
    PUPPET
    
    # Apply dconf
    apply_manifest(dconf_init, catch_failures: true)
    apply_manifest(dconf_init, catch_changes: true)
    # Apply dconf::profile
    apply_manifest(dconf_profile, catch_failures: true)
    apply_manifest(dconf_profile, catch_changes: true)
    # Apply dconf::db
    apply_manifest(dconf_db, catch_failures: true)
    apply_manifest(dconf_db, catch_changes: true)
  end

  describe package('dconf') do
    it { is_expected.to be_installed }
  end

end
