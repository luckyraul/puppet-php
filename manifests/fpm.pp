# Class php::fpm
class php::fpm (
    $ensure = $php::ensure,
    $pools  = $php::params::fpm_pools
) inherits php::params {

    $real_package = "${php::params::package_prefix}${php::params::fpm_package}"

    validate_string($ensure)
    validate_hash($pools)

    anchor { 'php::fpm::begin': } ->
    package { $real_package:
      ensure  => $ensure,
      require => Class['::php::packages'],
    } ->
    anchor { 'php::fpm::end': }
}
