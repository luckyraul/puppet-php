# Manage fpm service
#
# === Parameters
#
# [*service_name*]
#   name of the php-fpm service
#
# [*ensure*]
#   'ensure' value for the service
#
# [*enable*]
#   Defines if the service is enabled

class php::fpm::service(
    $service_name = $php::params::fpm_service_name,
    $service_ensure = $php::fpm_service_ensure,
    $service_enable = $php::fpm_service_enable,
) inherits php::params {

    service { $service_name:
        ensure     => $service_ensure,
        enable     => $service_enable,
        hasrestart => true,
        hasstatus  => true,
    }
}
