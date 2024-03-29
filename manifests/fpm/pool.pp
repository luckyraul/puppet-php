define php::fpm::pool (
  $ensure                    = 'present',
  $listen                    = '127.0.0.1:9000',
  $listen_backlog            = '-1',
  $listen_allowed_clients    = undef,
  $listen_owner              = undef,
  $listen_group              = undef,
  $listen_mode               = undef,
  $user                      = $php::params::fpm_user,
  $group                     = $php::params::fpm_group,
  $pm                        = 'ondemand',
  $pm_max_children           = '50',
  $pm_start_servers          = '5',
  $pm_min_spare_servers      = '5',
  $pm_max_spare_servers      = '35',
  $pm_max_requests           = '0',
  $pm_process_idle_timeout   = '10s',
  $pm_status_path            = undef,
  $ping_path                 = undef,
  $ping_response             = 'pong',
  $access_log                = undef,
  $access_log_format         = "%R - %u %t \"%m %r\" %s",
  $request_terminate_timeout = '0',
  $request_slowlog_timeout   = '0',
  $security_limit_extensions = undef,
  $slowlog                   = "/var/log/php-fpm/${name}-slow.log",
  $template                  = 'php/fpm/pool.conf.erb',
  $rlimit_files              = undef,
  $rlimit_core               = undef,
  $chroot                    = undef,
  $chdir                     = undef,
  $clear_env                 = 'yes',
  $catch_workers_output      = 'no',
  $decorate_workers_output   = undef,
  $env                       = [],
  $env_value                 = {},
  $options                   = {},
  $php_value                 = {},
  $php_flag                  = {},
  $php_admin_value           = {},
  $php_admin_flag            = {},
  $php_directives            = [],
  $base_dir                  = undef,
  $version                   = $php::version,
  $other_versions            = $php::multi_version,
) {
  $group_final = $group ? {
    undef   => $user,
    default => $group
  }

  $pool = $title

  if ($ensure == 'absent') {
    unique(concat($other_versions, $version, $php::version)).each |String $value| {
      file { "/etc/php/${value}/fpm/pool.d/${name}.conf":
        ensure => $ensure,
        notify => Class['php::fpm::service'],
      }
    }
  } else {
    $real_package = "php${version}-${php::params::fpm_package}"

    unique(concat($other_versions, $version, $php::version)).each |String $value| {
      if ($value == $version) {
        file { "/etc/php/${value}/fpm/pool.d/${name}.conf":
          ensure  => file,
          mode    => '0644',
          owner   => root,
          group   => root,
          notify  => Class['php::fpm::service'],
          require => Package[$real_package],
          content => template($template),
        }
      } else {
        file { "/etc/php/${value}/fpm/pool.d/${name}.conf":
          ensure => 'absent',
          notify => Class['php::fpm::service'],
        }
      }
    }
  }
}
