# Class php::newrelic
class php::newrelic (
    $ensure       = 'present',
    $package_name = 'newrelic-php5',
    $settings     = $php::newrelic_settings,
    $configile    = $php::newrelic_configfile,
) inherits php::params {

  package { $package_name:
    ensure  => $ensure,
  }

  exec { 'newrelic_install':
    command  => '/usr/bin/newrelic-install purge ; NR_INSTALL_SILENT=yes /usr/bin/newrelic-install install',
    provider => 'shell',
    user     => 'root',
    group    => 'root',
    creates  => "${php::params::config_root}/mods-available/newrelic.ini"
  }

  create_ini_settings($settings, {'path' => $configile, require => Exec['newrelic_install']})

  Package[$package_name] -> Exec['newrelic_install']
}
