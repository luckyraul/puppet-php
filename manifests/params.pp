# == Class: php::params
class php::params inherits php::globals {

    $ensure = present
    $composer_source  = 'https://getcomposer.org/composer.phar'
    $composer_path    = '/usr/local/bin/composer'
    $phpunit_source   = 'https://phar.phpunit.de/phpunit.phar'
    $phpunit_path     = '/usr/local/bin/phpunit'

    $fpm_pools        = { 'www' => {} }
    $fpm_service_enable  = true
    $fpm_service_ensure  = 'running'

    $fpm_user  = 'www-data'
    $fpm_group = 'www-data'

    $opc_config =  {
      '' => {
        'opcache.memory_consumption' => '128',
        'opcache.max_accelerated_files' => '99000',
        'opcache.enable_cli' => '1',
      },
    }

    if $::hardwaremodel == 'x86_64' {
        $package_suffix = '-64'
    } else {
        $package_suffix = ''
    }

    $ioncube_server = 'http://downloads3.ioncube.com/loader_downloads/'
    # http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz
    $ioncube_loader_base = 'ioncube_loader_lin'
    $ioncube_archive = "ioncube_loaders_lin_x86${package_suffix}.tar.gz"

    case $::operatingsystem {
        'Debian', 'Ubuntu': {
          case $global_php_version {
            /^7/: {
              $config_root          = "/etc/php/${global_php_version}"
              $fpm_service_name     = "php${global_php_version}-fpm"
              $ext_tool_enable      = "/usr/sbin/phpenmod -v ${global_php_version}"
              $ext_tool_query       = "/usr/sbin/phpquery -v ${global_php_version}"
              $package_prefix       = "php${global_php_version}-"
              $fpm_pid_file         = "/run/php${global_php_version}-fpm.pid"
              $fpm_error_log        = "/var/log/php${global_php_version}-fpm.log"
              # $fpm_default_params   = {
              #     'user'                 => 'www-data',
              #     'group'                => 'www-data',
              #     'listen'               => '/run/php/php7.0-fpm.sock',
              #     'listen.owner'         => 'www-data',
              #     'listen.group'         => 'www-data',
              #     'pm'                   => dynamic,
              #     'pm.max_children'      => 5,
              #     'pm.start_servers'     => 2,
              #     'pm.min_spare_servers' => 1,
              #     'pm.max_spare_servers' => 3,
              # }
            }
            default: {
              $config_root          = '/etc/php5'
              $fpm_service_name     = 'php5-fpm'
              $fpm_pid_file         = '/run/php5-fpm.pid'
              $fpm_error_log        = '/var/log/php5-fpm.log'
              $ext_tool_enable      = '/usr/sbin/php5enmod'
              $ext_tool_query       = '/usr/sbin/php5query'
              $package_prefix       = 'php5-'
              # $fpm_default_params   = {
              #     'user'                 => 'www-data',
              #     'group'                => 'www-data',
              #     'listen'               => '/var/run/php5-fpm.sock',
              #     'listen.owner'         => 'www-data',
              #     'listen.group'         => 'www-data',
              #     'pm'                   => dynamic,
              #     'pm.max_children'      => 5,
              #     'pm.start_servers'     => 2,
              #     'pm.min_spare_servers' => 1,
              #     'pm.max_spare_servers' => 3,
              #     'chdir'                => '/'
              # }
            }
          }
          $common_package = ['cli','common']
          $dev_package = 'dev'
          $fpm_package = 'fpm'
          $fpm_pool_dir = "${config_root}/fpm/pool.d/"

          $fpm_service_settings = {
              daemonize                   => 'yes',
              file                        => "${config_root}/fpm/php-fpm.conf",
              pid_file                    => $fpm_pid_file,
              error_log                   => $fpm_error_log,
              syslog_facility             => 'daemon',
              syslog_ident                => 'php-fpm',
              log_level                   => 'notice',
              emergency_restart_threshold => '0',
              emergency_restart_interval  => '0',
              process_control_timeout     => '0',
              process_max                 => '0',
              rlimit_files                => nil,
              systemd_interval            => nil,
              pool_base_dir               => $fpm_pool_dir,
          }

          $default_config = {
            'PHP' => {
              'short_open_tag' => 'On',
              'always_populate_raw_post_data' => '-1',
            },
            'Date' => {
              'date.timezone' => '"Europe/Moscow"',
            }
          }

          case $::lsbdistcodename {
              'jessie', 'stretch', 'buster': {
                  $release = $::lsbdistcodename
                  $manage_repos = false
              }
              'xenial': {
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

    $newrelic_configfile = "${config_root}/mods-available/newrelic.ini"
    $newrelic_settings = {
      'newrelic' => {
        'newrelic.enabled' => true,
        'newrelic.license' => '${NR_INSTALL_KEY}',
        'newrelic.appname' => '${NR_INSTALL_APP}',
      }
    }
}
