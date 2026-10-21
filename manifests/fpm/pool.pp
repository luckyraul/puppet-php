# Configure fpm pools
#
# === Parameters
#
# See the official php-fpm documentation for parameters that are not
# documented here: http://php.net/manual/en/install.fpm.configuration.php.
#
# [*ensure*]
#   Remove pool if set to `'absent'`, add otherwise
#
# [*listen*]
#   On what socket to listen for FastCGI connections, i.e.
#   `'127.0.0.1:9000'' or `'/var/run/php5-fpm.sock'`
#
# [*listen_backlog*]
#
# [*listen_allowed_clients*]
#
# [*listen_owner*]
#   Set owner of the Unix socket
#
# [*listen_group*]
#   Set the group of the Unix socket
#
# [*listen_mode*]
#
# [*user*]
#   The user that php-fpm should run as
#
# [*group*]
#   The group that php-fpm should run as
#
# [*apparmor_hat*]
#   The Apparmor hat to use
#
# [*pm*]
#
# [*pm_max_children*]
#
# [*pm_start_servers*]
#
# [*pm_min_spare_servers*]
#
# [*pm_max_spare_servers*]
#
# [*pm_max_requests*]
#
# [*pm_process_idle_timeout*]
#
# [*pm_status_path*]
#
# [*ping_path*]
#
# [*ping_response*]
#
# [*access_log*]
#   The path to the file to write access log requests to
#
# [*access_log_format*]
#   The format to save the access log entries as
#
# [*request_terminate_timeout*]
#
# [*request_slowlog_timeout*]
#
# [*security_limit_extensions*]
#
# [*slowlog*]
#
# [*template*]
#   The template to use for the pool
#
# [*rlimit_files*]
#
# [*rlimit_core*]
#
# [*chroot*]
#
# [*chdir*]
#
# [*catch_workers_output*]
#
# [*decorate_workers_output*]
#
# [*include*]
#   Other configuration files to include on this pool
#
# [*env*]
#   List of environment variables that are passed to the php-fpm from the
#   outside and will be available to php scripts in this pool
#
# [*env_value*]
#   Hash of environment variables and values as strings to use in php
#   scripts in this pool
#
# [*clear_env*]
#   Whether the environment should be cleared.
#
# [*options*]
#   An optional hash for any other data.
#
# [*php_value*]
#   Hash of php_value directives
#
# [*php_flag*]
#   Hash of php_flag directives
#
# [*php_admin_value*]
#   Hash of php_admin_value directives
#
# [*php_admin_flag*]
#   Hash of php_admin_flag directives
#
# [*php_directives*]
#   List of custom directives that are appended to the pool config
#
# [*base_dir*]
#   The folder that contains the php-fpm pool configs. This defaults to a
#   sensible default depending on your operating system, like
#   '/etc/php5/fpm/pool.d' or '/etc/php-fpm.d'
# [*version*]
#   Version of package
# [*other_versions*]
#   Version of packages
define php::fpm::pool (
  Enum['present', 'absent'] $ensure                    = 'present',
  String[1] $listen                                    = '127.0.0.1:9000',
  Integer[-1] $listen_backlog                          = -1,
  Optional[String[1]] $listen_allowed_clients          = undef,
  Optional[String[1]] $listen_owner                    = undef,
  Optional[String[1]] $listen_group                    = undef,
  Optional[Stdlib::Filemode] $listen_mode              = undef,
  String[1] $user                                      = $php::params::fpm_user,
  String[1] $group                                     = $php::params::fpm_group,
  Optional[String[1]] $apparmor_hat                    = undef,
  String[1] $pm                                        = 'ondemand',
  Integer[1] $pm_max_children                          = 50,
  Integer[0] $pm_start_servers                         = 5,
  Integer[0] $pm_min_spare_servers                     = 5,
  Integer[0] $pm_max_spare_servers                     = 35,
  Integer[0] $pm_max_requests                          = 0,
  Php::Duration $pm_process_idle_timeout               = '10s',
  Optional[Stdlib::Absolutepath] $pm_status_path       = undef,
  Optional[Stdlib::Absolutepath] $ping_path            = undef,
  String[1] $ping_response                             = 'pong',
  Optional[Stdlib::Absolutepath] $access_log           = undef,
  String[1] $access_log_format                         = '"%R - %u %t \"%m %r\" %s"',
  Php::Duration $request_terminate_timeout             = 0,
  Php::Duration $request_slowlog_timeout               = 0,
  Array[String[1]] $security_limit_extensions          = [],
  Stdlib::Absolutepath $slowlog                        = "/var/log/php-fpm/${name}-slow.log",
  String[1] $template                                  = 'php/fpm/pool.conf.erb',
  Optional[Integer] $rlimit_files                      = undef,
  Optional[Integer] $rlimit_core                       = undef,
  Optional[Stdlib::Absolutepath] $chroot               = undef,
  Optional[Stdlib::Absolutepath] $chdir                = undef,
  Enum['yes', 'no'] $catch_workers_output              = 'no',
  Optional[Enum['yes', 'no']] $decorate_workers_output = undef,
  Optional[String[1]] $include                         = undef,
  Array[String[1]] $env                                = [],
  Hash $env_value                                      = {},
  Enum['yes', 'no'] $clear_env                         = 'yes',
  Hash $options                                        = {},
  Hash $php_value                                      = {},
  Hash $php_flag                                       = {},
  Hash $php_admin_value                                = {},
  Hash $php_admin_flag                                 = {},
  Array[String[1]] $php_directives                     = [],
  Optional[Stdlib::Absolutepath] $base_dir             = undef,
  String[1] $version                                   = $php::version,
  Array[String[1]] $other_versions                     = $php::multi_version,
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
          mode    => '0640',
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
