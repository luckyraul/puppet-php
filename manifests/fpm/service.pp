# Manage fpm service
class php::fpm::service(
  $file                        = $php::params::fpm_config_file,
  $pid_file                    = $php::params::fpm_pid_file,
  $error_log                   = $php::params::fpm_error_log,
  $syslog_facility             = 'daemon',
  $syslog_ident                = 'php-fpm',
  $log_level                   = 'notice',
  $emergency_restart_threshold = '0',
  $emergency_restart_interval  = '0',
  $process_control_timeout     = '0',
  $process_max                 = '0',
  $rlimit_files                = undef,
  $systemd_interval            = undef,
  $pool_base_dir               = $php::params::fpm_pool_dir,
) inherits php::params {

    file { $file:
        ensure  => file,
        mode    => '0644',
        owner   => root,
        group   => root,
        notify  => Service[$php::params::fpm_service_name],
        content => template('php/fpm/php-fpm.conf.erb'),
    }

    create_ini_settings($php::fpm_service_settings, {'path' => $file, require => File[$file]})

    service { $php::params::fpm_service_name:
        ensure     => $php::fpm_service_ensure,
        enable     => $php::fpm_service_enable,
        hasrestart => true,
        hasstatus  => true,
    }
}
