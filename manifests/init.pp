# @summary Installs and configures dconf
#
# @example Declaring the class
#   include dconf
#
# @param manage_packages Whether to manage the dconf packages.
#
# @param packages The packages required for dconf management. Typically sourced via hiera.
#
# @param db_base_dir The base directory for dconf db files
#
# @param profile_base_dir The base directory for dconf profiles
#
# @param profiles Hash of dconf profiles
#
# @param dbs Hash of dconf databases, settings and locks
class dconf (
  Boolean $manage_packages = true,
  Array $packages = [],
  Stdlib::Absolutepath $db_base_dir = '/etc/dconf/db',
  Stdlib::Absolutepath $profile_base_dir = '/etc/dconf/profile',
  Optional[Hash] $profiles = undef,
  Optional[Hash] $dbs = undef,
) {
  # Ensure dconf and config directories
  if $manage_packages {
    $packages.each | String $package | {
      package { $package:
        ensure => 'installed',
        before => Exec['dconf_update'],
      }
    }
  }
  file { '/etc/dconf':
    ensure => 'directory',
    mode   => '0755',
    owner  => 'root',
    group  => 'root',
  }
  file { $profile_base_dir:
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => File['/etc/dconf'],
  }
  file { $db_base_dir:
    ensure  => 'directory',
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => File['/etc/dconf'],
  }
  # Generate resources from hiera
  if $profiles {
    $profiles.each |String $profile, Hash $values| {
      ensure_resource('dconf::profile', $profile, $values)
    }
  }
  if $dbs {
    $dbs.each |String $db, Hash $values| {
      ensure_resource('dconf::db', $db, $values)
    }
  }
  # Execute dconf update
  exec { 'dconf_update':
    path        => ['/usr/bin','/usr/sbin'],
    command     => 'dconf update',
    refreshonly => true,
    umask       => '0022',
  }
}
