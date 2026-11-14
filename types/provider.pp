type Php::Provider = Enum[
  # do nothing
  'none',

  # php
  'pecl',
  'pear',

  # Debuntu
  'dpkg',
  'apt',

  # RHEL
  'yum',
  'rpm',
  'dnf'
]
