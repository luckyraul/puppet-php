# Class php::dev
class php::dev (
  $ensure = $php::ensure
)
{
  $real_package = "${php::params::package_prefix}${php::params::dev_package}"

  package { $real_package:
    ensure  => $ensure,
    require => Class['php::packages'],
  }
}
