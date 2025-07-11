# @summary Generate arbitrary dconf keyfiles
#
# @example Deploy a simple keyfile under /etc/dconf/db/local.d/
#   dconf::keyfile { "example_default":
#     ensure    => 'present',
#     settings  => {
#       'system/proxy/http' => {
#         'host'    => "'172.16.0.1'",
#         'enabled' => 'true',
#     },
#     parent_db => '/etc/dconf/db/local.d',
#     priority  => '00',
#   }
#
# @param ensure Set the state of the resource
# 
# @param settings A hash of dconf settings
# 
# @param parent_db Absolute path to the dconf db directory (e.g. '/etc/dconf/db/local.d')
#
# @param priority Numerical value used to set the keyfile priority (keyfiles are read in lexicographical order)
#
# @param filename Name of the keyfile to create
#
# @param file_path Absolute path of the keyfile to create
#
# @param file_mode File permissions for dconf keyfile
#
define dconf::keyfile (
  Hash $settings,
  Stdlib::Absolutepath $parent_db,
  Pattern[/^[0-9]+$/] $priority = '50',
  String $filename = "${priority}-${name}",
  Stdlib::Absolutepath $file_path = "${parent_db}/${filename}",
  String $file_mode = '0644',
  Enum['present','absent'] $ensure = 'present',
) {
  include dconf
  case $ensure {
    'present': {
      # Generate config file content
      $_db_file_header = epp('dconf/header.epp')
      $_db_file_body = epp('dconf/db.epp', {
          'settings' => $settings
        }
      )
      file { $file_path:
        ensure  => 'file',
        mode    => $file_mode,
        content => "${_db_file_header}${_db_file_body}",
        require => File[$parent_db],
        notify  => Exec['dconf_update'],
      }
    }
    'absent': {
      file { $file_path:
        ensure => 'absent',
        force  => true,
        notify => Exec['dconf_update'],
      }
    }
    default: {
      warning("Unknown resource state for dconf config file.\nReceived: ${ensure}\nExpected: 'present' OR 'absent'")
    }
  }
}
