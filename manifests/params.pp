# == Class: php::params
class php::params inherits php::globals {
  $ensure = present
  $composer_version = '2.2.18'
  $composer_source  = "https://getcomposer.org/download/${composer_version}/composer.phar"
  $composer_path    = '/usr/local/bin/composer'

  $fpm_pools        = { 'www' => {} }
  $fpm_service_enable  = true
  $fpm_service_ensure  = 'running'

  $fpm_user  = 'www-data'
  $fpm_group = 'www-data'

  $opc_config = {
    '' => {
      'opcache.memory_consumption' => '256',
      'opcache.max_accelerated_files' => '99000',
      'opcache.enable_cli' => '1',
    },
  }

  if $facts['os']['hardware'] == 'x86_64' {
    $package_suffix = '-64'
  } else {
    $package_suffix = ''
  }

  case $facts['os']['name'] {
    'Debian', 'Ubuntu': {
      $config_root          = "/etc/php/${global_php_version}"
      $fpm_service_name     = "php${global_php_version}-fpm"
      $ext_tool_enable      = "/usr/sbin/phpenmod -v ${global_php_version}"
      $ext_tool_query       = "/usr/sbin/phpquery -v ${global_php_version}"
      $package_prefix       = "php${global_php_version}-"
      $fpm_pid_file         = "/run/php/php${global_php_version}-fpm.pid"
      $fpm_error_log        = "/var/log/php${global_php_version}-fpm.log"
      $common_package = ['cli','common','xml']
      $dev_package = 'dev'
      $fpm_package = 'fpm'
      $fpm_pool_dir = "${config_root}/fpm/pool.d/"

      $fpm_service_settings = {
        daemonize                   => 'yes',
        syslog_facility             => 'daemon',
        syslog_ident                => 'php-fpm',
        log_level                   => 'notice',
        log_limit                   => nil,
        emergency_restart_threshold => '0',
        emergency_restart_interval  => '0',
        process_control_timeout     => '0',
        process_max                 => '0',
        rlimit_files                => nil,
        systemd_interval            => nil,
      }

      $default_config = {
        'PHP' => {
          'expose_php' => 'Off',
        },
        'Date' => {
          'date.timezone' => '"Europe/Moscow"',
        },
      }

      case $facts['os']['distro']['codename'] {
        'jessie', 'stretch', 'buster', 'bullseye': {
          $release = $facts['os']['distro']['codename']
          $manage_repos = false
        }
        'xenial': {
          $manage_repos = false
        }
        default: {
          fail("Unsupported release: ${facts['facts['os']['distro']['codename']']}")
        }
      }
    }
    default: {
      fail("Unsupported os: ${facts['facts['os']['name']']}")
    }
  }

  $newrelic_configfile = "${config_root}/mods-available/newrelic.ini"
  $newrelic_settings = {
    'newrelic' => {
      'newrelic.enabled' => true,
      'newrelic.license' => '${NR_INSTALL_KEY}',
      'newrelic.appname' => '${NR_INSTALL_APP}',
    },
  }
}
