# @summary Installs and configures dconf
#
# @example Declaring the class
#   include dconf
#
# @param manage_packages Whether to manage the dconf packages.
#
# @param packages The packages required for dconf management. Typically sourced via hiera.
#
# @param profiles Hash of dconf profiles
#
# @param dbs Hash of dconf databases, settings and locks
class dconf (
  Boolean $manage_packages = true,
  Array $packages = [],
  Optional[Hash] $profiles = undef,
  Optional[Hash] $dbs = undef,
) {
  if $manage_packages {
    ensure_packages($packages)
  }
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
  exec { 'dconf_update':
    path        => ['/usr/bin','/usr/sbin'],
    command     => 'dconf update',
    refreshonly => true,
    umask       => '0022',
  }
}
