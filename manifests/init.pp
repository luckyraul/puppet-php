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
    $fpm_pools            = $php::params::fpm_pools,
    $fpm_service_ensure   = $php::params::fpm_service_ensure,
    $fpm_service_enable   = $php::params::fpm_service_enable,
    $fpm_service_settings = {},
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
    $multi_version        = [],
    ) inherits php::params {

    # validate_string($ensure)
    # validate_bool($fpm)
    # validate_bool($dev)
    # validate_bool($composer)
    # validate_bool($phpunit)
    # validate_hash($settings)

    Exec {
      path => ['/bin', '/usr/bin','/usr/sbin']
    }

    anchor { 'php::begin': }
      -> class { 'php::repo': }
      -> class { 'php::packages': }
      -> class { 'php::config': }
      -> anchor { 'php::end': }

    if $manage_repos or $newrelic {
      Class['php::repo'] -> Exec['apt_update'] -> Class['php::packages']
    }

    create_resources('php::extension', $extensions, {
      require => Class['php::config'],
      before  => Anchor['php::end']
    })

    if $fpm {
        Class['php::packages'] -> class { 'php::fpm':} -> Class['php::config']
    }

    if $pear {
        Class['php::packages'] -> class { 'php::pear':} -> Anchor['php::end']
    }

    if $dev {
        Class['php::packages'] -> class { 'php::dev':} -> Anchor['php::end']
    }

    if $newrelic {
        Class['php::packages'] -> class { 'php::newrelic':} -> Anchor['php::end']
    }

    if $ioncube {
        Class['php::packages'] -> class { 'php::ioncube':} -> Anchor['php::end']
    }

    if $composer {
        Class['php::packages'] -> class { 'php::composer':} -> Anchor['php::end']
    }

    if $phpunit {
        Class['php::packages'] -> class { 'php::phpunit':} -> Anchor['php::end']
    }

    if $docker {
        ensure_packages(['git', 'openssh-client','gosu'], {'ensure' => 'present'})

        file {'/entrypoint.sh':
            owner   => root,
            group   => root,
            mode    => '0755',
            content => template('php/docker/entrypoint.sh.erb'),
        }
    }
}
