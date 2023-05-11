# dconf
## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with dconf](#setup)
    * [What dconf affects](#what-dconf-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with dconf](#beginning-with-dconf)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module will install dconf and allow you to manage GNOME desktop environment via Puppet.

## Setup

### What dconf affects **OPTIONAL**

- dconf package
- dconf profiles under `/etc/dconf/profile/`
- dconf db files under `/etc/dconf/db/`
- dconf db lock files under `/etc/dconf/db/YOUR_PROFILE/locks/`

### Setup Requirements

See module dependencies for more details.

### Beginning with dconf

For basic use of this module, first make sure the module is installed on your puppet-server, then add the following to your manifest:
```
include dconf
```
On its own, this will simply install the dconf packages for your distro.

## Usage

Include usage examples for common use cases in the **Usage** section. Show your
users how to use your module to solve problems, and be sure to include code
examples. Include three to five examples of the most important or common tasks a
user can accomplish with your module. Show users how to accomplish more complex
tasks that involve different types, classes, and functions working in tandem.
### Creating a dconf profile
```
dconf::profile { 'example_profile':
  entries => [
    'user' => {
      'type'  => 'user',
      'order' => 10,
     },
    'local' => {
      'type'  => 'system',
      'order' => 21,
    },
    'site' => {
      'type'  => 'system',
      'order' => 22,
    },
  ],
}
```
Will result in the following profile at `/etc/dconf/profile/example_profile`
```
user-db:user
system-db:local
system-db:site
```
### Creating a dconf settings file with locks
```
dconf::db { 'local':
  settings => {
    'system/proxy/http' => {
      'host' => '172.16.0.1',
      'enabled' => 'true',
    },
  locks => [
    'system/proxy/http/host',
    'system/proxy/http/enabled',
  ],
```
Will result in the following dconf database structure:
```
/etc/dconf/
|-- db
|   |-- local
|   `-- local.d
|       |-- 00-default
|       `-- locks
|           `-- 00-default
```
#### local.d/00-default
```
[system/proxy/http]
host = '172.16.0.1'
enabled = true
```
#### local.d/locks/00-default
```
system/proxy/http/enabled
system/proxy/http/host
```
### Configure dconf with hiera
This module can also be configured entirely using hiera.
To configure the above with hiera, use the following snippet:
```
dconf::profiles:
  'example_profile':
    entries:
      'user':
        type: 'user'
        order: 10
      'local':
        type: 'system'
        order: 21
      'site':
        type: 'system'
        order 22
dconf::dbs:
  'local':
    settings:
      'system/proxy/http':
        'host': "'172.16.0.1'"
        'enabled': 'true'
    locks:
      - 'system/proxy/http/host'
      - 'system/proxy/http/enabled'

```
Note that some dconf values must be double quoted to ensure the resulting dconf ini keyfile contains the correct data.

### Removing dconf profiles and databases
To remove dconf profiles and databases, you can use the `ensure` parameter.
#### Resource declaration
```
dconf::profile { 'example_profile':
  ensure => 'absent',
}
dconf::db { 'local':
  ensure => 'absent',
}
```
#### Hiera declaration
```
dconf::profiles:
  'example_profile':
    ensure: 'absent'
dconf::dbs:
  'local':
    ensure: 'absent'
```
Ensuring the absence of a dconf database will cause the db file, db directory, and associated locks to all be removed. If you just want to remove the locks you can supply an empty array for the resource:
```
dconf::dbs:
  'local':
    locks: []
```
## Limitations

This module only ensures the specified settings are present in your dconf keyfiles. Unmanaged INI settings in your keyfiles will not be automatically removed.
This is a limitation of the `puppetlabs/inifile` module used to generate the dconf keyfiles.

## Development

When contributing, please check your code conforms to the Puppet language style guide: https://www.puppet.com/docs/puppet/latest/style_guide.html

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
