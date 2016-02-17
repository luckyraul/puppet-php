# Manage fpm service
class php::fpm::service(
) inherits php::params {

    create_ini_settings($php::fpm_service_settings, {'path' => $php::params::fpm_config_file}) <| |> ~> Service[$php::params::fpm_service_name]

    service { $php::params::fpm_service_name:
        ensure     => $php::fpm_service_ensure,
        enable     => $php::fpm_service_enable,
        hasrestart => true,
        hasstatus  => true,
    }
}
