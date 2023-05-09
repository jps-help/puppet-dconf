# @summary Create dconf profiles
#
# @example Creating dconf profiles
#   dconf::profile { 'example_profile':
#     entries => [
#       'user-db:user',
#       'system-db:local',
#       'system-db:site',
#     ],
#   }
#
# @param profile_dir Absolute path to dconf profile directory
#
# @param profile_file Absolute path to dconf profile file
#
# @param profile_file_mode File permissions for dconf profile file
#
# @param entries List of entries to include in the dconf profile
define dconf::profile (
  Stdlib::Absolutepath $profile_dir = '/etc/dconf/profile',
  Stdlib::Absolutepath $profile_file = "${profile_dir}/${name}",
  String $profile_file_mode = '0644',
  Optional[Array] $entries = undef,
) {
  concat { "profile_${name}":
    target => $profile_file,
    mode   => $profile_file_mode,
  }
  $entries.each |String[1] $entry| {
    concat::fragment { "profile_${name}_${entry}":
      target  => $profile_file,
      content => $entry,
      require => File[$profile_file],
    }
  }
}
