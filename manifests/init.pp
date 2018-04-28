# package_alternatives
#
# Defined type for easy management of software packages with different
# (alternative) names across platforms.
#
# @summary Easy management of packages with different names across platforms.
#
# @param ensure Package ensure state.
# @param alternatives Structure with package alternatives.
# @param fail_missing Fail if no alternative package.
# @param pkg_alias Package resource alias name.
# @param platform Current platform detection override.
#
# @example
#   package_alternatives { 'man-db':
#     ensure       => present,
#     fail_missing => false,
#     alternatives => {
#       'debian'   => 'man-db',
#       'redhat-5' => 'man',
#       'redhat-6' => 'man',
#       'redhat'   => 'man-db',
#       'sles'     => 'man'
#     },
#   }
#
# @example
#   package_alternatives { 'zsh':
#     ensure       => present,
#     alternatives => 'my-own-zsh',
#   }
#
# @example
#   package_alternatives { 'zsh':
#     ensure => present,
#   }
define package_alternatives (
  Enum['present', 'installed', 'latest', 'absent', 'purged'] $ensure,
  Boolean $fail_missing      = true,
  Variant[String[1], Hash[String[1], String[1]], Hash[String[1], Hash[String[1], String[1]]]] $alternatives = $title,
  String[1] $pkg_alias       = $title,
  Optional[String] $platform = undef,
) {
  if $alternatives =~ Hash {
    if has_key($alternatives,$name) {
      $_alts = $alternatives[$name]
    } else {
      $_alts = $alternatives
    }
  } else {
    $_alts = $alternatives
  }

  if $_alts =~ Hash {
    $a   = downcase($facts['os']['architecture'])
    $os  = downcase($facts['os']['name'])
    $of  = downcase($facts['os']['family'])
    $rel = downcase($facts['os']['release']['full'])
    $maj = downcase($facts['os']['release']['major'])

    # user specified platform override
    if $platform and length($platform)>0 and has_key($_alts, downcase($platform)) {
      $_pkg_name = $_alts[downcase($platform)]

    # e.g. centos-6.4-x86_64 centos-6.4
    } elsif has_key($_alts, "${os}-${rel}-${a}") {
      $_pkg_name = $_alts["${os}-${rel}-${a}"]
    } elsif has_key($_alts, "${os}-${rel}") {
      $_pkg_name = $_alts["${os}-${rel}"]

    # e.g. centos-6-x86_64 centos-6
    } elsif has_key($_alts, "${os}-${maj}-${a}") {
      $_pkg_name = $_alts["${os}-${maj}-${a}"]
    } elsif has_key($_alts, "${os}-${maj}") {
      $_pkg_name = $_alts["${os}-${maj}"]

    # e.g. centos-x86_64, centos
    } elsif has_key($_alts, "${os}-${a}") {
      $_pkg_name = $_alts["${os}-${a}"]
    } elsif has_key($_alts, $os) {
      $_pkg_name = $_alts[$os]

    # e.g. redhat-6.4-x86_64 redhat-6.4
    } elsif has_key($_alts, "${of}-${rel}-${a}") {
      $_pkg_name = $_alts["${of}-${rel}-${a}"]
    } elsif has_key($_alts, "${of}-${rel}") {
      $_pkg_name = $_alts["${of}-${rel}"]

    # e.g. redhat-6-x86_64 redhat-6
    } elsif has_key($_alts, "${of}-${maj}-${a}") {
      $_pkg_name = $_alts["${of}-${maj}-${a}"]
    } elsif has_key($_alts, "${of}-${maj}") {
      $_pkg_name = $_alts["${of}-${maj}"]

    # e.g. redhat-x86_64 redhat
    } elsif has_key($_alts, "${of}-${a}") {
      $_pkg_name = $_alts["${of}-${a}"]
    } elsif has_key($_alts, $of) {
      $_pkg_name = $_alts[$of]

    } else {
      $_pkg_name = undef
    }
  } elsif $_alts =~ String {
    $_pkg_name = $_alts
  }

  if ! empty($_pkg_name) and ! defined(Package[$_pkg_name]) and ! defined(Package[$pkg_alias]) {
    ensure_resource('package', $_pkg_name, {
      'ensure' => $ensure,
      'alias'  => $pkg_alias,
    })
  } elsif $fail_missing {
    fail("Missing alternative package for '${name}'")
  }
}
