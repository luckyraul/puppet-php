# Class php::ioncube
class php::ioncube (
    $ensure          = 'present',
    $php_version     = $php::version,
    $ioncube_server  = $php::params::ioncube_server,
    $ioncube_archive = $php::params::ioncube_archive,
    $ioncube_base    = $php::params::ioncube_loader_base,
    $ioncube_ts      = false,
    $install_prefix  = '/usr/local',
) inherits php::params {

  Exec {
    path => ['/bin', '/usr/bin','/usr/sbin']
  }

  if $ensure == 'present' {

    exec { 'retrieve_ioncubeloader':
      cwd     => '/tmp',
      command => "/usr/bin/wget ${$ioncube_server}${ioncube_archive} && /bin/tar xzf ${ioncube_archive} && /bin/mv ioncube/ ${install_prefix} && /usr/bin/touch ${install_prefix}/ioncube/.installed",
      creates => "${install_prefix}/ioncube/.installed"
    }

    if $ioncube_ts {
      $ioncube_loader = "${ioncube_base}_${php_version}_ts.so"
    } else {
      $ioncube_loader = "${ioncube_base}_${php_version}.so"
    }

    file { "${php::params::config_root}/mods-available/ioncube.ini":
      ensure  => $ensure,
      content => ";Managed by puppet\n; priority=01\nzend_extension=${install_prefix}/ioncube/${ioncube_loader}\n"
    }

    exec { 'enabling_ioncube':
      cwd         => '/tmp',
      command     => 'php5enmod ioncube',
      refreshonly => true,
    }

    Exec['retrieve_ioncubeloader']
      -> File["${php::params::config_root}/mods-available/ioncube.ini"]
      -> Exec['enabling_ioncube']

  } else {

    file { "${install_prefix}/ioncube":
      ensure  => $ensure,
      backup  => false,
      recurse => true,
      force   => true,
    }

    file { "/tmp/${ioncube_archive}":
      ensure => $ensure,
      backup => false,
    }
  }
}
