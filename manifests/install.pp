# @summary Install Dconf
#
# Install dependent packages for dconf. This class is typically called by the main class automatically
# if you have `dconf::manage_packages => true` (default).
#
# @example
#   include dconf::install
class dconf::install {
  $dconf::packages.each | String $package | {
    package { $package:
      ensure => 'installed',
    }
  }
}
