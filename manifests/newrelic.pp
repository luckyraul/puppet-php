# Class php::newrelic
class php::newrelic (
    $ensure  = $php::newrelic,
    $license = $php::newrelic_licence
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
  } ->
  package { 'newrelic-php5':
    ensure  => $ensure,
  }

  exec { 'newrelic_install':
    command  => '/usr/bin/newrelic-install purge ; NR_INSTALL_SILENT=yes /usr/bin/newrelic-install install',
    provider => 'shell',
    user     => 'root',
    group    => 'root',
    creates  => "${php::params::config_root}/mods-available/newrelic.ini"
  }

  create_ini_settings($php::newrelic_settings, {'path' => $php::newrelic_config, require => Exec['newrelic_install']})

  Exec['apt_update'] -> Package['newrelic-php5'] -> Exec['newrelic_install']
}
