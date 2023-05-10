# @summary Installs and configures dconf
#
# @example Declaring the class
#   include dconf
#
# @param manage_packages Whether to manage the dconf packages.
#
# @param dconf_packages The packages required for dconf management.
#
# @param profiles Hash of dconf profiles
#
# @param dbs Hash of dconf db and settings
class dconf (
  Boolean $manage_packages = true,
  Array $dconf_packages = ['dconf-cli'],
  Optional[Hash] $profiles = undef,
  Optional[Hash] $dbs = undef,
) {
  if $manage_packages {
    ensure_packages($dconf_packages)
  }
  if $profiles {
    $profiles.each |String $profile, Dconf::DBEntries $values| {
      ensure_resource('dconf::profile', $profile, { 'entries' => $values })
    }
  }
  if $dbs {
    $dbs.each |String $db, Hash $values| {
      ensure_resource('dconf::db', $db, { 'settings' => $values })
    }
  }
  exec { 'dconf_update':
    path        => ['/usr/bin','/usr/sbin'],
    command     => 'dconf update',
    refreshonly => true,
  }
}
