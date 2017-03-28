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
    $version              = $php::params::global_php_version,
    $ensure               = $php::params::ensure,
    $manage_repos         = $php::params::manage_repos,
    $packages             = [],
    $fpm                  = true,
    $fpm_service_ensure   = $php::params::fpm_service_ensure,
    $fpm_service_enable   = $php::params::fpm_service_enable,
    $fpm_service_settings = $php::params::fpm_service_settings,
    $dev                  = false,
    $pear                 = false,
    $composer             = true,
    $phpunit              = false,
    $newrelic             = false,
    $newrelic_settings    = $php::params::newrelic_settings,
    $newrelic_configfile  = $php::params::newrelic_configfile,
    $ioncube              = false,
    $docker               = false,
    $settings             = {},
    $extensions           = {},
    ) inherits php::params {

    validate_string($ensure)
    validate_bool($fpm)
    validate_bool($dev)
    validate_bool($composer)
    validate_bool($phpunit)
    validate_hash($settings)

    Exec {
      path => ['/bin', '/usr/bin','/usr/sbin']
    }

    if $manage_repos {
        class { 'php::repo': } -> Anchor['php::begin']
    }

    anchor { 'php::begin': }
      -> class { 'php::packages': }
      -> class { 'php::config': }
      -> anchor { 'php::end': }

    create_resources('php::extension', $extensions, {
      require => Class['php::config'],
      before  => Anchor['php::end']
    })

    if $fpm {
        Anchor['php::begin'] -> class { 'php::fpm':} -> Class['php::config']
    }

    if $pear {
        Anchor['php::begin'] -> class { 'php::pear':} -> Anchor['php::end']
    }

    if $dev {
        Anchor['php::begin'] -> class { 'php::dev':} -> Anchor['php::end']
    }

    if $newrelic {
        Class['php::packages'] -> class { 'php::newrelic':} -> Anchor['php::end']
    }

    if $ioncube {
        Class['php::packages'] -> class { 'php::ioncube':} -> Anchor['php::end']
    }

    if $composer {
        Anchor['php::begin'] -> class { 'php::composer':} -> Anchor['php::end']
    }

    if $phpunit {
        Anchor['php::begin'] -> class { 'php::phpunit':} -> Anchor['php::end']
    }

    if $docker {
        file {'/entrypoint.sh':
            owner   => root,
            group   => root,
            mode    => '0755',
            content => template('php/docker/entrypoint.sh.erb'),
        }
    }
}
