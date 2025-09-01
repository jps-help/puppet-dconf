# @summary Generate arbitrary dconf locks files
#
# @example Deploy a simple locks file under /etc/dconf/db/local.d/locks/
#   dconf::db_locks { 'example_default':
#     ensure => 'present',
#     parent_db => '/etc/dconf/db/local.d',
#     priority => '00',
#     locks => [
#       'system/proxy/http/host',
#       'system/proxy/http/enabled',
#     ],
#   }
#
# @param ensure Set the state of the resource
# 
# @param locks A hash of dconf locks
# 
# @param parent_db Absolute path to the dconf db directory (e.g. '/etc/dconf/db/local.d')
#
# @param locks_dir Absolute path to the dconf locks directory
#
# @param priority Numerical value used to set the locks file priority (locks files are read in lexicographical order)
#
# @param filename Name of the locks file to create
#
# @param file_path Absolute path of the locks file to create
#
# @param file_mode File permissions for dconf locks file
define dconf::db_locks (
  Array $locks,
  Stdlib::Absolutepath $parent_db,
  Stdlib::Absolutepath $locks_dir = "${parent_db}/locks",
  Pattern[/^[0-9]+$/] $priority = '50',
  String $filename = "${priority}-${name}",
  Stdlib::Absolutepath $file_path = "${locks_dir}/${filename}",
  String $file_mode = '0644',
  Enum['present','absent'] $ensure = 'present',
) {
  include dconf
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
