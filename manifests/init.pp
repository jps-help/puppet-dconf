# @summary Base dconf class
#
# Installs and configures dconf
#
# @example Declaring the class
#   include dconf
#
# @param manage_package Whether to manage the dconf packages.
#
# @param dconf_packages The packages required for dconf management.
#
# @param dconf_profiles Hash of dconf profiles
class dconf (
  Boolean $manage_package = true,
  Array $dconf_packages = ['dconf-cli'],
  Optional[Hash] $dconf_profiles = undef,
  Optional[Hash] $dconf_configs = undef,
) {
  if $manage_package {
    ensure_packages($dconf_packages)
  }
  if $dconf_profiles {
    $dconf_profiles.each |String $profile, Hash $values| {
      ensure_resource('dconf::profile',$profile,$values)
    }
  }
  if $dconf_configs {
    $dconf_configs.each |String $db, Hash $values| {
      ensure_resource('dconf::config',$db,$values)
    }
  }
}
