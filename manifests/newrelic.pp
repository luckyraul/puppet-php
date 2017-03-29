# Class php::newrelic
class php::newrelic (
    $ensure  = $php::newrelic,
    $license = $php::newrelic_licence,
    $package_name = 'newrelic-php5',
) inherits php::params {

  apt::source { 'newrelic':
    location => 'http://apt.newrelic.com/debian/',
    repos    => 'non-free',
    key      => {
      id  => 'B60A3EC9BC013B9C23790EC8B31B29E5548C16BF',
      key => 'https://download.newrelic.com/548C16BF.gpg',
    },
    include  => {
      src => false,
    },
    release  => 'newrelic',
    notify => Exec['apt_update']
  } ->
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

  create_ini_settings($php::newrelic_settings, {'path' => $php::newrelic_configfile, require => Exec['newrelic_install']})

  Package[$package_name] -> Exec['newrelic_install']
}
