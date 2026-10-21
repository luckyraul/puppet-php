# PHP params class
#
class php::params inherits php::globals {
  $manage_repos = false
  $composer_version = '2.2.30'
  $composer_source  = "https://getcomposer.org/download/${composer_version}/composer.phar"
  $composer_path    = '/usr/local/bin/composer'
  $php_version = $php::globals::globals_php_version

  $fpm_user  = 'www-data'
  $fpm_group = 'www-data'
  $fpm_package = 'fpm'
  $fpm_pools   = { 'www' => {} }

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

  case $facts['os']['family'] {
    'Debian': {
      $config_root = "/etc/php/${php_version}"
      $package_prefix = $php::globals::package_prefix
      $common_packages = ['cli','common','xml']
    }
    default: {
      fail("Unsupported osfamily: ${facts['os']['family']}")
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
