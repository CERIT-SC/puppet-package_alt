define package_alt (
  $ensure,
  $fail_missing = true,
  $alternatives = $title,
  $alias        = $title,
  $platform     = ''
) {
  validate_bool($fail_missing)
  validate_string($alias)
  validate_string($platform)

  if is_hash($alternatives) {
    if has_key($alternatives,$name) {
      $_alts = $alternatives[$name]
    } else {
      $_alts = $alternatives
    }
  } else {
    $_alts = $alternatives
  }

  if is_hash($_alts) {
    $os = downcase($::operatingsystem)
    $of = downcase($::osfamily)

    if has_key($_alts, downcase($platform)) {
      $_pkg_name = $_alts[downcase($platform)]
    } elsif has_key($_alts, downcase("${os}${::operatingsystemrelease}")) {
      $_pkg_name = $_alts[downcase("${os}${::operatingsystemrelease}")]
    } elsif has_key($_alts, downcase("${os}${::operatingsystemmajrelease}")) {
      $_pkg_name = $_alts[downcase("${os}${::operatingsystemmajrelease}")]
    } elsif has_key($_alts, downcase($os)) {
      $_pkg_name = $_alts[downcase($os)]
    } elsif has_key($_alts, downcase("${of}${::operatingsystemrelease}")) {
      $_pkg_name = $_alts[downcase("${of}${::operatingsystemrelease}")]
    } elsif has_key($_alts, downcase("${of}${::operatingsystemmajrelease}")) {
      $_pkg_name = $_alts[downcase("${of}${::operatingsystemmajrelease}")]
    } elsif has_key($_alts, downcase($of)) {
      $_pkg_name = $_alts[downcase($of)]
    }

  } elsif is_string($_alts) {
    $_pkg_name = $_alts

  } else {
    fail('$alternatives must be hash or string')
  }

  if $_pkg_name {
    package { $_pkg_name:
      ensure => $ensure,
      alias  => $alias,
    }
  } elsif $fail_missing {
    fail("Missing alternative package for '${name}'")
  }
}
