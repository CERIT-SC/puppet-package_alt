package_alternatives { 'man-db':
  ensure       => present,
  fail_missing => false,
  alternatives => {
    'debian'   => 'man-db',
    'redhat-5' => 'man',
    'redhat-6' => 'man',
    'redhat'   => 'man-db',
    'sles'     => 'man'
  },
}
