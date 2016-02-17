# == Class: php::params
class php::params {
    $ensure = present
    $composer_source  = 'https://getcomposer.org/composer.phar'
    $composer_path    = '/usr/local/bin/composer'
    $phpunit_source   = 'https://phar.phpunit.de/phpunit.phar'
    $phpunit_path     = '/usr/local/bin/phpunit'
    $fpm_pools        = { 'www' => {} }
    $fpm_service_enable  = true
    $fpm_service_ensure  = 'running'
    $fpm_service_settings = {
        'global' {
            'daemonize': 'yes'
        }
    }
    case $::operatingsystem {
        'Debian': {
          $config_root = '/etc/php5'
          $common_package = ['cli','common']
          $dev_package = 'dev'
          $fpm_package = 'fpm'
          $fpm_config_file = "${config_root}/fpm/php-fpm.conf"
          $fpm_service_name = 'php5-fpm'
          $package_prefix = 'php5-'
          $ext_tool_enable  = '/usr/sbin/php5enmod'
          $ext_tool_query   = '/usr/sbin/php5query'
          case $::lsbdistcodename {
              'wheezy': {
                  $version = '5.5'
                  $release = 'wheezy-php55'
                  $manage_repos = true
              }
              'jessie': {
                  $version = '5.6'
                  $release = $::lsbdistcodename
                  $manage_repos = false
              }
              default: {
                  fail("Unsupported release: ${::lsbdistcodename}")
              }
          }
        }
        default: {
            fail("Unsupported os: ${::operatingsystem}")
        }
    }
}
