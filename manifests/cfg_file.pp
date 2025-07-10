# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   dconf::cfg_file { 'namevar': }
define dconf::cfg_file (
  Hash $settings,
  Stdlib::Absolutepath $parent_db,
  Pattern[/^[0-9]+$/] $priority = 50,
  String $filename = "${priority}-${name}",
  Stdlib::Absolutepath $file_path = "${parent_db}/${filename}",
  String $file_mode = '0644',
  Enum['present','absent'] $ensure = 'present',
) {
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
