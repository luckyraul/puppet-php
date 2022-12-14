# Class php::fpm
class php::fpm (
  $ensure  = $php::ensure,
  $pools   = $php::fpm_pools,
  $version = $php::version,
  $other_versions = $php::multi_version
) inherits php::params {
  unique(concat($other_versions, $version)).each |String $value| {
    package { "php${value}-${php::params::fpm_package}" :
      ensure  => $ensure,
      require => Class['php::packages'],
    }

    Package["php${value}-${php::params::fpm_package}"] -> Class['php::fpm::service']
  }

  $other_versions.each |String $value| {
    php::fpm::pool { "${value}-www":
      listen  => "/var/run/php-fpm${value}-www.sock",
      pm      => 'ondemand',
      version => $value,
    }
  }

  class { 'php::fpm::service': }

  create_resources(php::fpm::pool, $pools)
}
