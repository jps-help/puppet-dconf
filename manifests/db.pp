# @summary Create dconf db keyfiles
#
# @example Create a dconf db keyfile with given settings
#   dconf::db { 'local':
#     settings => {
#       'system/proxy/http' => {
#         'host' => "'172.16.0.1'",
#         'enabled' => 'true',
#       },
#       'org/gnome/desktop/background' => {
#         'picture-uri' => 'file:///usr/local/rupert-corp/company-wallpaper.jpeg',
#       },
#     },
#   }
#
# @example Lockdown dconf settings
#   dconf::db { 'local':
#     settings => {
#       'system/proxy/http' => {
#         'host' => "'172.16.0.1'",
#         'enabled' => 'true',
#       },
#     locks => [
#       'system/proxy/http/host',
#       'system/proxy/http/enabled',
#     ],
#
# @example Managing multiple config files for the same db
#   dconf::db { 'system-proxy':
#     db_dir      => '/etc/dconf/db/local.d',
#     db_filename => 'system-proxy',
#     settings    => {
#       'system/proxy/http' => {
#         'host'    => "'172.16.0.1'",
#         'enabled' => 'true',
#       },
#     },
#   }
#   dconf::db { 'disable-microphone':
#     db_dir      => '/etc/dconf/db/local.d',
#     db_filename => 'disable-micrphone',
#     settings    => {
#       'org/gnome/desktop/privacy' => {
#         'disable-microphone' => 'true',
#       },
#     },
#   }
#
# @param settings Hash of dconf settings
#
# @param locks Array of dconf settings to lock
#
# @param db_dir Absolute path of the dconf db directory
#
# @param db_filename Name of the dconf db file
#
# @param db_file Absolute path of the dconf db file
#
# @param locks_dir Absolute path of the dconf db locks directory
#
# @param locks_filename Name of the dconf locks file
#
# @param locks_file Absolute path of the dconf db locks file
#
# @param db_dir_mode File permissions for dconf db directory
#
# @param db_file_mode File permissions for dconf db file
#
# @param locks_dir_mode File permissions for dconf db locks directory
#
# @param locks_file_mode File permissions for dconf db locks file
#
# @param purge Whether to purge unmanaged files (keyfiles and lock files)
#
# @param ensure Whether to ensure presence or absence of the resource
#
# @param inifile_defaults Default parameters to parse to inifile provider
#
define dconf::db (
  Optional[Hash] $settings = undef,
  Optional[Array] $locks = undef,
  Stdlib::Absolutepath $db_dir = "${dconf::db_base_dir}/${name}.d",
  String $db_filename = '00-default',
  Stdlib::Absolutepath $db_file = "${db_dir}/${db_filename}",
  Stdlib::Absolutepath $locks_dir = "${db_dir}/locks",
  String $locks_filename = '00-default',
  Stdlib::Absolutepath $locks_file = "${locks_dir}/${locks_filename}",
  String $db_dir_mode  = '0755',
  String $db_file_mode = '0644',
  String $locks_dir_mode = '0755',
  String $locks_file_mode = '0644',
  Boolean $purge = true,
  Enum['present','absent'] $ensure = 'present',
  Hash $inifile_defaults = { ensure => 'present', path => $db_file, notify => Exec['dconf_update'], require => File[$db_file], },
) {
  case $ensure {
    'present': {
      ensure_resource(file, $db_dir, {
          ensure  => 'directory',
          mode    => $db_dir_mode,
          purge   => $purge,
          recurse => $purge,
          force   => $purge,
      })
      file { $db_file:
        ensure  => 'file',
        mode    => $db_file_mode,
        require => File[$db_dir],
      }
      if $settings {
        $settings.each |String $section, Hash $key_vals| {
          $key_vals.each |String $setting, $value| {
            ini_setting { "db_${name}_settings_${section}_${setting}":
              path    => $db_file,
              section => $section,
              setting => $setting,
              value   => $value,
              notify  => Exec['dconf_update'],
            }
          }
        }
      }
      if $locks {
        ensure_resource(file, $locks_dir, {
            ensure  => 'directory',
            mode    => $locks_dir_mode,
            purge   => $purge,
            recurse => $purge,
        })
        concat { "db_${name}_locks":
          path    => $locks_file,
          mode    => $locks_file_mode,
          order   => 'alpha',
          require => File[$locks_dir],
        }
        $locks.each |$lock| {
          concat::fragment { "db_${name}_locks_${lock}":
            target  => $locks_file,
            content => "${lock}\n",
            require => Concat["db_${name}_locks"],
            notify  => Exec['dconf_update'],
          }
        }
      }
    }
    'absent': {
      file { $db_dir:
        ensure  => 'absent',
        purge   => true,
        recurse => true,
        force   => true,
      }
      -> file { "${dconf::db_base_dir}/${name}":
        ensure => 'absent',
        force  => true,
        notify => Exec['dconf_update'],
      }
    }
    default: {
      warning("Unknown resource state for dconf database.\nReceived: ${ensure}\nExpected: 'present' OR 'absent'")
    }
  }
}
