# == Class: php
# === Parameters
#
# [*ensure*]
#   Specify which version of PHP packages to install, defaults to 'present'.
#   Please note that 'absent' to remove packages is not supported!
#
# [*manage_repos*]
#   Include repository (dotdeb) to install recent PHP from
#
# [*fpm*]
#   Install and configure php-fpm
#
# [*fpm_service_enable*]
#   Enable/disable FPM service
#
# [*fpm_service_ensure*]
#   Ensure FPM service is either 'running' or 'stopped'
#
# [*dev*]
#   Install php header files, needed to install pecl modules
#
# [*composer*]
#   Install and auto-update composer
#
# [*phpunit*]
#   Install phpunit

class php (
    $version              = $php::params::version,
    $ensure               = $php::params::ensure,
    $manage_repos         = $php::params::manage_repos,
    $packages             = [],
    $fpm                  = true,
    $fpm_service_ensure   = $php::params::fpm_service_ensure,
    $fpm_service_enable   = $php::params::fpm_service_enable,
    $fpm_service_settings = $php::params::fpm_service_settings,
    $dev                  = false,
    $composer             = true,
    $phpunit              = false,
    ) inherits php::params {

    validate_string($ensure)
    validate_bool($fpm)
    validate_bool($dev)
    validate_bool($composer)
    validate_bool($phpunit)


    if $manage_repos {
        class { 'php::repo': } -> Anchor['php::begin']
    }

    anchor { 'php::begin': } -> class { 'php::packages': } -> anchor { 'php::end': }

    if $fpm {
        Anchor['php::begin'] -> class { 'php::fpm':} -> Anchor['php::end']
    }

    if $dev {
        Anchor['php::begin'] -> class { 'php::dev':} -> Anchor['php::end']
    }

    if $composer {
        Anchor['php::begin'] -> class { 'php::composer':} -> Anchor['php::end']
    }

    if $phpunit {
        Anchor['php::begin'] -> class { 'php::phpunit':} -> Anchor['php::end']
    }

}
