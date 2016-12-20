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
        'global' => {
            'daemonize' => 'yes',
        }
    }

    $opc_config =  {
      '' => {
        'opcache.memory_consumption' => '128',
        'opcache.max_accelerated_files' => '99000',
        'opcache.enable_cli' => '1',
      },
    }
    case $::operatingsystem {
        'Debian': {
          $config_root = '/etc/php5'
          $common_package = ['cli','common']
          $dev_package = 'dev'
          $fpm_package = 'fpm'
          $fpm_pool_dir = "${config_root}/fpm/pool.d/"
          $fpm_config_file = "${config_root}/fpm/php-fpm.conf"
          $fpm_service_name = 'php5-fpm'
          $package_prefix = 'php5-'
          $ext_tool_enable  = '/usr/sbin/php5enmod'
          $ext_tool_query   = '/usr/sbin/php5query'
          $fpm_default_params = {
              'user'                 => 'www-data',
              'group'                => 'www-data',
              'listen'               => '/var/run/php5-fpm.sock',
              'listen.owner'         => 'www-data',
              'listen.group'         => 'www-data',
              'pm'                   => dynamic,
              'pm.max_children'      => 5,
              'pm.start_servers'     => 2,
              'pm.min_spare_servers' => 1,
              'pm.max_spare_servers' => 3,
              'chdir'                => '/'
          }
          case $::lsbdistcodename {
              'wheezy': {
                  $version = '5.5'
                  $release = 'wheezy-php55'
                  $manage_repos = true
              }
              'jessie': {
                  $version = '5.6'
                  $default_config = {
                    'PHP' => {
                      'short_open_tag' => 'On',
                      'always_populate_raw_post_data' => '-1',
                    },
                    'Date' => {
                      'date.timezone' => '"Europe/Moscow"',
                    }
                  }
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
