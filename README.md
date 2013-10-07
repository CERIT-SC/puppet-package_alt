# Puppet package\_alt module

This module provides a defined resource `package_alt` for easy
installation of software packages with different (alternative)
names across platforms.

### Requirements

Module has been tested on:

* Puppet 3.3
* Debian and Red Hat family systems

Required modules:

* stdlib (https://github.com/puppetlabs/puppetlabs-stdlib)

# Quick Start

Full configuration options:

```
package_alt { 'resource title':
  ensure       => ...,         # Resource package ensure state
  fail_missing => boolean,     # Fail on no alternative package.
  alternatives => string|hash, # Structure with package alternatives.
  platform     => string,      # Current platform detection override.
}
```

### Software alternatives structure

`$alternatives` accepts:

* string for no alternative (defaults to resource `$title`)

* hash of platforms and alternative package names, e.g.:

```puppet
$software = {
  'debian' => 'openssh-client',
  'redhat' => 'openssh-clients'
}
```

* hash of resource names with with hash or string containing
  package name or platforms hash of alternatives, e.g.:

```puppet
$software = {
  'bash' => 'bash',
  'openssh-client' => {
    'debian' => 'openssh-client',
    'redhat' => 'openssh-clients',
  }
}
```


### Platforms resolution order

Lower cased:

0. Custom `$platform` parameter
1. `${::operatingsystem}${::operatingsystemrelease}` (*centos6.4*)
2. `${::operatingsystem}${::operatingsystemmajrelease}` (*centos6*)
3. `${::operatingsystem}` (*centos*)
4. `${::osfamily}${::operatingsystemrelease}` (*redhat6.4*)
5. `${::osfamily}${::operatingsystemmajrelease}` (*redhat6*)
6. `${::osfamily}` (*redhat*)

### Software alternatives structure

Parameter `$alternatives` accepts:

* string for no alternative (defaults to resource `$title`)

```puppet
$software = 'bash'
```

* hash of platforms and alternative package names, e.g.:

```puppet
$software = {
  'debian' => 'openssh-client',
  'redhat' => 'openssh-clients'
}
```

* hash of resource names with with hash or string containing 
  package name or platforms hash of alternatives, e.g.:


```puppet
$software = {
  'bash' => 'bash',
  'openssh-client' => {
    'debian' => 'openssh-client',
    'redhat' => 'openssh-clients',
  }
}
```

# Example

```puppet
$software = {
  'rsync'  => 'rsync',         # same name on all platforms
  'ash'    => {
    'debian'  => 'ash'         # just Debian supported
  },
  'tshark' => {
    'debian6' => 'tshark',     # just Debian 6 and any
    'redhat'  => 'wireshark',  # RedHat family supported
  },
}

package_alt { keys($software):
  ensure       => present,
  alternatives => $software,
  fail_missing => false,       # skip packages with no alternative on platform
}
```

***

CERIT Scientific Cloud, <support@cerit-sc.cz>
