define php::fpm::pool (
    $ensure = 'present',
    $params = {}
) {
    $file = "${php::params::fpm_pool_dir}${name}.conf"
    $settings = merge($php::params::fpm_default_params, $params)
    file { $file:
        ensure => $ensure,
        mode   => '0644',
        owner  => root,
        group  => root
    }

    create_ini_settings($php::fpm_service_settings, {'path' => $file})
}
