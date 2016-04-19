# Class php::fpm
class php::fpm (
    $ensure  = $php::ensure,
    $pools   = $php::params::fpm_pools,
    $version = $php::version,
) inherits php::params {

    $real_package = "${php::params::package_prefix}${php::params::fpm_package}"

    case $version {
        '5.5': {
            case $::lsbdistcodename {
                'jessie': {
                    apt::pin { 'downgrade_php_fpm':
                      ensure   => 'present',
                      packages => [$real_package],
                      priority => 500,
                      release  => 'wheezy-php55',
                    }
                }
            }
        }
    }


    validate_string($ensure)
    validate_hash($pools)

    anchor { 'php::fpm::begin': } ->
    package { $real_package:
      ensure  => $ensure,
      require => Class['php::packages'],
    } ->
    class { 'php::fpm::service': } ->
    anchor { 'php::fpm::end': }

    create_resources(php::fpm::pool, $pools)
}
