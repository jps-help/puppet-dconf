# @summary A short summary of the purpose of this defined type.
#
# A description of what this defined type does
#
# @example
#   dconf::locks_file { 'namevar': }
define dconf::locks_file (
  Array $locks,
  Stdlib::Absolutepath $parent_db,
  Stdlib::Absolutepath $locks_dir = "${parent_db}/locks",
  Pattern[/^[0-9]+$/] $priority = 50,
  String $filename = "${priority}-${name}",
  Stdlib::Absolutepath $file_path = "${locks_dir}/${filename}",
  String $file_mode = '0644',
  Enum['present','absent'] $ensure = 'present',
) {
  case $ensure {
    'present': {
      $_locks_file_header = epp('dconf/header.epp')
      $_locks_file_body = epp('dconf/locks.epp', {
          'locks' => $locks
        }
      )
      file { $file_path:
        ensure  => $ensure,
        mode    => $file_mode,
        content => "${_locks_file_header}${_locks_file_body}",
        require => File[$locks_dir],
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
      warning("Unknown resource state for dconf locks file.\nReceived: ${ensure}\nExpected: 'present' OR 'absent'")
    }
  }
}
