# Class php::newrelic
# === Parameters
#
# [*ensure*]
#   
# [*package_name*]
#   
# [*settings*]
#   
# [*configpath*]
#
class php::newrelic (
  Enum['absent', 'present', 'latest'] $ensure = $php::package_ensure,
  String[1] $package_name = 'newrelic-php5',
  Hash $settings = $php::newrelic_settings,
  String[1] $configpath = $php::newrelic_configfile,
) {
  package { $package_name:
    ensure => $ensure,
  }

  exec { 'newrelic_install':
    command  => '/usr/bin/newrelic-install purge ; NR_INSTALL_SILENT=yes /usr/bin/newrelic-install install',
    provider => 'shell',
    user     => 'root',
    group    => 'root',
    creates  => $configpath,
  }

  inifile::create_ini_settings($settings, { 'path' => $configpath, require => Exec['newrelic_install'] })

  Package[$package_name] -> Exec['newrelic_install']
}
