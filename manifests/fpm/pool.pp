define php::fpm::pool (
    $ensure = 'present',
    $params = {}
) {
    $file = "${php::params::fpm_pool_dir}${name}.conf"

    $merged_config = merge($php::params::fpm_default_params, $params)

    $settings = {
        "${title}" => $merged_config
    }

    file { $file:
        ensure => $ensure,
        mode   => '0644',
        owner  => root,
        group  => root
    }

    create_ini_settings($settings, {'path' => $file})
}
