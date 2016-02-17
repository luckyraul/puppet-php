# == Class: php::params
class php::params {
    $version = undef
    $ensure = present
    $composer_source  = 'https://getcomposer.org/composer.phar'
    $composer_path    = '/usr/local/bin/composer'
    $phpunit_source   = 'https://phar.phpunit.de/phpunit.phar'
    $phpunit_path     = '/usr/local/bin/phpunit'
    $fpm_pools        = { 'www' => {} }
    case $::operatingsystem {
        'Debian': {
          $common_package = ['cli','common']
          $dev_package = 'dev'
          $fpm_package = 'fpm'
          $package_prefix = 'php5-'
          $ext_tool_enable  = '/usr/sbin/php5enmod'
          $ext_tool_query   = '/usr/sbin/php5query'
          $manage_repos = true
        }
        default: {
            fail("Unsupported os: ${::operatingsystem}")
        }
    }
}
