define package_alternatives (
  $ensure,
  $fail_missing = true,
  $alternatives = $title,
  $pkg_alias    = $title,
  $platform     = ''
) {
  validate_bool($fail_missing)
  validate_string($pkg_alias)
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
    $a   = downcase($::architecture)
    $os  = downcase($::operatingsystem)
    $of  = downcase($::osfamily)
    $rel = downcase($::operatingsystemrelease)
    $maj = downcase($::operatingsystemmajrelease)

    # user specified platform
    if has_key($_alts, downcase($platform)) {
      $_pkg_name = $_alts[downcase($platform)]

    # e.g. centos-6.4-x86_64 centos-6.4
    } elsif has_key($_alts, downcase("${os}-${rel}-${a}")) {
      $_pkg_name = $_alts[downcase("${os}-${rel}-${a}")]
    } elsif has_key($_alts, downcase("${os}-${rel}")) {
      $_pkg_name = $_alts[downcase("${os}-${rel}")]

    # e.g. centos-6-x86_64 centos-6
    } elsif has_key($_alts, downcase("${os}-${maj}-${a}")) {
      $_pkg_name = $_alts[downcase("${os}-${maj}-${a}")]
    } elsif has_key($_alts, downcase("${os}-${maj}")) {
      $_pkg_name = $_alts[downcase("${os}-${maj}")]

    # e.g. centos-x86_64, centos
    } elsif has_key($_alts, downcase("${os}-${a}")) {
      $_pkg_name = $_alts[downcase("${os}-${a}")]
    } elsif has_key($_alts, downcase($os)) {
      $_pkg_name = $_alts[downcase($os)]

    # e.g. redhat-6.4-x86_64 redhat-6.4
    } elsif has_key($_alts, downcase("${of}-${rel}-${a}")) {
      $_pkg_name = $_alts[downcase("${of}-${rel}-${a}")]
    } elsif has_key($_alts, downcase("${of}-${rel}")) {
      $_pkg_name = $_alts[downcase("${of}-${rel}")]

    # e.g. redhat-6-x86_64 redhat-6
    } elsif has_key($_alts, downcase("${of}-${maj}-${a}")) {
      $_pkg_name = $_alts[downcase("${of}-${maj}-${a}")]
    } elsif has_key($_alts, downcase("${of}-${maj}")) {
      $_pkg_name = $_alts[downcase("${of}-${maj}")]

    # e.g. redhat-x86_64 redhat
    } elsif has_key($_alts, downcase("${of}-${a}")) {
      $_pkg_name = $_alts[downcase("${of}-${a}")]
    } elsif has_key($_alts, downcase($of)) {
      $_pkg_name = $_alts[downcase($of)]

    } else {
      $_pkg_name = undef
    }

  } elsif is_string($_alts) {
    $_pkg_name = $_alts

  } else {
    fail('$alternatives must be hash or string')
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
