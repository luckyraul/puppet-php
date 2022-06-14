# Manage fpm service
class php::fpm::service(
  $settings = $php::fpm_service_settings,
  $version = $php::version,
  $other_versions = $php::multi_version,
) inherits php::params {

    unique(concat($other_versions, $version)).each |String $value| {
      $config = deep_merge(
        $php::params::fpm_service_settings,
        php::fpm_settings($value),
        $settings
      )

      file { $config['file']:
          ensure  => file,
          mode    => '0644',
          owner   => root,
          group   => root,
          notify  => Service["php${value}-fpm"],
          content => template('php/fpm/php-fpm.conf.erb'),
      }

      service { "php${value}-fpm":
          ensure     => $php::fpm_service_ensure,
          enable     => $php::fpm_service_enable,
          hasrestart => true,
          hasstatus  => true,
      }

    }

    file { '/run/php':
      ensure => directory,
      owner   => root,
      group   => root,
    }
}
