# Install and configure php fpm
#
# === Parameters
# [*version*]
#   Version of packages
# [*ensure*]
#   Status of packages
# [*pools*]
#   The pool list
# [*other_versions*]
#   Version of packages
#
class php::fpm (
  String[1] $version = $php::version,
  Enum['absent', 'present', 'latest'] $ensure = $php::package_ensure,
  Hash $pools = $php::fpm_pools,
  Array[String[1]] $other_versions = $php::multi_version
) {
  assert_private()
  unique(concat($other_versions, $version)).each |String $value| {
    package { "php${value}-${php::params::fpm_package}" :
      ensure  => $ensure,
      require => Class['php::packages'],
    }

    Package["php${value}-${php::params::fpm_package}"] -> Class['php::fpm::service']
  }

  $other_versions.each |String $value| {
    php::fpm::pool { "${value}-www":
      listen  => "/run/php-fpm${value}-www.sock",
      pm      => 'ondemand',
      version => $value,
    }
  }

  class { 'php::fpm::service': }

  create_resources(php::fpm::pool, $pools)
}
