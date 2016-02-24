define php::fpm::pool (
    $ensure = 'present',
    $params = {}
) {
    $file = "${php::params::fpm_pool_dir}${name}.conf"

    $merged_config = merge($php::params::fpm_default_params, $params)

    $settings = {
        "${title}" => $merged_config
    }

    #notify{"{title} The value is: ${settings}": }

    $real_package = "${php::params::package_prefix}${php::params::fpm_package}"

    if ($ensure == 'absent') {
        file { $file:
            ensure => $ensure,
            notify => Class['php::fpm::service'],
        }
    } else {
        file { $file:
            ensure  => file,
            mode    => '0644',
            owner   => root,
            group   => root,
            notify  => Class['php::fpm::service'],
            require => Package[$real_package],
            content => template('php/fpm/pool.conf.erb'),
        }
        create_ini_settings($settings, {'path' => $file, require => File[$file]})
    }
}
