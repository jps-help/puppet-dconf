# Changelog

All notable changes to this project will be documented in this file.
## Release 0.2.3
### Changed
- Ensure `dconf::packages` are installed before calling `Exec['dconf_update']`

## Release 0.2.2
### Added
- Declare support for Puppet 8
- Declare support for Ubuntu 24.04
- Add templates for db and locks files
- Add commented headers for managed files
### Changed
- Use templates for db and locks files instead of inifile
- Update spec tests for db and lock file generation
### Removed
- Remove dependency on puppetlabs-inifile

## Release 0.2.1
### Added
- Ensure `/etc/dconf` directory
### Fixed
- Prevent dependency failures if `/etc/dconf` is not present. Can occur if dconf package is not installed yet and is explicitly not managed by the module.

## Release 0.2.0
### Breaking
- Remove `dconf::db::base_dir` parameter
- Remove `dconf::db::base_dir_mode` in favour of hard-coded value `0755`
- Remove `dconf::profile::profile_dir` parameter
- Remove `dconf::profile::profile_dir_mode` parameter
### Added
- New parameter `dconf::db_base_dir`
- New parameter `dconf::profile_base_dir`
- Unit testing and CI/CD workflows
### Changed
- `dconf::db::db_dir` parameter is now formed using `dconf::db_base_dir` parameter
- `dconf::profile::profile_file` parameter is now formed using `dconf::profile_base_dir` parameter
- Convert if/elsif logic to case statement for `dconf::db`
- Convert if/elsif logic to case statement for `dconf::profile`
- Replace `create_ini_settings()` function in `dconf::db` with native Puppet resource iteration
- `/etc/dconf/db` directory is now ensured by the main class
- `/etc/dconf/profile` directory is now ensured by the main class
- Replace `ensure_packages()` function in main class with native Puppet resource iteration
- Remove unused `dconf::profile::purge` parameter
- Set upper bounderies for module dependencies
### Fixed
- Fixed incorrect directory mode for generated `dconf::db` resources
- Fixed hiera lookups

## Release 0.1.1
### Added
- Allow multiple db files/lockfiles to be managed under a single dconf db directory ([#5](https://github.com/jps-help/dconf/issues/5))
- Specify umask for `dconf update` command ([#7](https://github.com/jps-help/dconf/issues/7))
- Allow dconf::db resource to remove empty lock directories ([#9](https://github.com/jps-help/dconf/issues/9))
- Added REFERENCE.md
### Fixed
- Corrected usage documentation for dconf::profile
- Corrected usage documentation for dconf::db
## Release 0.1.0

**Features**

**Bugfixes**

**Known Issues**
