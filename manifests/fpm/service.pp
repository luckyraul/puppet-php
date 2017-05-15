# Manage fpm service
class php::fpm::service(
  $settings = $php::fpm_service_settings
) inherits php::params {

    $config = deep_merge($php::params::fpm_service_settings, $settings)

    file { $config['file']:
        ensure  => file,
        mode    => '0644',
        owner   => root,
        group   => root,
        notify  => Service[$php::params::fpm_service_name],
        content => template('php/fpm/php-fpm.conf.erb'),
    }

    service { $php::params::fpm_service_name:
        ensure     => $php::fpm_service_ensure,
        enable     => $php::fpm_service_enable,
        hasrestart => true,
        hasstatus  => true,
    }
}
