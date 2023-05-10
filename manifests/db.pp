# @summary Create dconf db keyfiles
#
# @example Create a dconf db keyfile with given settings
#   dconf::db { 'local':
#     settings => {
#       'system/proxy/http' => {
#         'host' => '172.16.0.1',
#         'enabled' => 'true',
#       },
#       'org/gnome/desktop/background' => {
#         'picture-uri' => 'file:///usr/local/rupert-corp/company-wallpaper.jpeg',
#       },
#     },
#   }
#
# @param settings Hash of dconf settings
#
# @param locks Array of dconf settings to lock
#
# @param base_dir Absolute path of the dconf db base directory
#
# @param db_dir Absolute path of the dconf db directory
#
# @param db_file Absolute path of the dconf db file
#
# @param locks_dir Absolute path of the dconf db locks directory
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
# @param inifile_defaults Default parameters to parse to inifile provider
#
# @param
define dconf::db (
  Optional[Hash] $settings = undef,
  Optional[Array] $locks = undef,
  Stdlib::Absolutepath $base_dir = '/etc/dconf/db',
  Stdlib::Absolutepath $db_dir = "${base_dir}/${name}.d",
  Stdlib::Absolutepath $db_file = "${db_dir}/00-default",
  Boolean $purge = true,
  Stdlib::Absolutepath $locks_dir = "${db_dir}/locks",
  Stdlib::Absolutepath $locks_file = "${locks_dir}/00-default",
  String $db_dir_mode  = '0755',
  String $db_file_mode = '0644',
  String $locks_dir_mode = '0755',
  String $locks_file_mode = '0644',
  Boolean $db_dir_purge = true,
  Hash $inifile_defaults = { ensure => 'present', path => $db_file, notify => Exec['dconf_update'], require => File[$db_file], },
) {
  file { $db_dir:
    ensure  => 'directory',
    mode    => $db_dir_mode,
    purge   => $purge,
    recurse => $purge,
  }
  file { $db_file:
    ensure  => 'file',
    mode    => $db_file_mode,
    require => File[$db_dir],
  }
  if $settings {
    inifile::create_ini_settings($settings,$inifile_defaults)
  }
  if $locks {
    file { $locks_dir:
      ensure  => 'directory',
      mode    => $locks_dir_mode,
      purge   => $purge,
      recurse => $purge,
    }
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
