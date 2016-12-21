# Install a PHP extension package
define php::extension (
  $ensure = 'installed',
  $provider = undef,
) {
  validate_string($ensure)

  if $provider == 'pecl' {
      $real_package = "pecl-${name}"
  } else {
      $real_package = $name
  }

  package { $real_package:
    ensure   => $ensure,
    provider => $provider,
    require  => [
        Class['php::pear'],
        Class['php::dev'],
    ],
  }
}
