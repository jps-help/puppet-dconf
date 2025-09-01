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

### What dconf affects

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

Below are some examples of how to use the module in your own environment.
### Creating a dconf profile
```
dconf::profile { 'user':
  entries => {
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
  },
}
```
Will result in the following profile at `/etc/dconf/profile/user`
```
user-db:user
system-db:local
system-db:site
```
### Creating a dconf settings file with locks
For a simple deployment, you may only need a single dconf keyfile and locks file.
You can create the dconf db itself, along with a keyfile and locks file using a single `dconf::db` resource.
```
dconf::db { 'local':
  settings => {
    'system/proxy/http' => {
      'host' => '172.16.0.1',
      'enabled' => 'true',
    },
  locks => [
    '/system/proxy/http/host',
    '/system/proxy/http/enabled',
  ],
```
Will result in the following dconf database structure:
```
/etc/dconf/
|-- db
|   |-- local
|   `-- local.d
|       |-- 00-local_default
|       `-- locks
|           `-- 00-local_default
```
#### local.d/00-default
```
[system/proxy/http]
host = '172.16.0.1'
enabled = true
```
#### local.d/locks/00-default
```
/system/proxy/http/enabled
/system/proxy/http/host
```
### Configure dconf with hiera
This module can also be configured entirely using hiera.
To configure the above example using only hiera, try the following snippet:
```
dconf::profiles:
  'user':
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
      - '/system/proxy/http/host'
      - '/system/proxy/http/enabled'

```
Note that some dconf values must be double quoted to ensure the resulting dconf ini keyfile contains the correct data type.

### Removing dconf profiles and databases
To remove dconf profiles and databases, you can use the `ensure` parameter.
#### Resource declaration
```
dconf::profile { 'user':
  ensure => 'absent',
}
dconf::db { 'local':
  ensure => 'absent',
}
```
#### Hiera declaration
```
dconf::profiles:
  'user':
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
### Working with multiple keyfiles and lock files
In some environments, it may be desirable to split your dconf configuration into multiple files for a given db.
You can do this using `dconf::db_keyfile` and `dconf::db_locks` resources.

First, create a `dconf::db` resource to create the necessary folder structure. The below snippet creates an empty dconf db folder structure.
```
dconf::db { 'example1':
  ensure => 'present',
  purge => true,
}
```
Now you can create any number of dconf keyfiles or locks files.

The title for each `dconf::db_keyfile` and `dconf::db_lockss` must be unique. Therefore, it's best to prefix each file with the name of the db it's being deployed to.
```
dconf::db_keyfile { 'example1_settings':
  ensure   => 'present',
  priority => '90',
  parent_db => '/etc/dconf/db/example1.d',
  settings => {
    'system/proxy/http' => {
      'host' => '172.16.0.1',
      'enabled' => 'true',
    },
  },
}

dconf::db_locks { 'example1_settings':
  ensure   => 'present',
  priority => '90'
  parent_db => '/etc/dconf/db/example1.d',
  locks => [
    '/system/proxy/http/host',
    '/system/proxy/http/enabled',
  ],
}
```
The above would result in the following structure:
```
/etc/dconf/
|-- db
|   |-- example1
|   `-- example1.d
|       |-- 90-example1_settings
|       `-- locks
|           `-- 90-example1_settings
```

## Limitations
No known limitations

## Development

When contributing, please check your code conforms to the Puppet language style guide: https://www.puppet.com/docs/puppet/latest/style_guide.html

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
