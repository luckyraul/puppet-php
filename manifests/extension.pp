# Install a PHP extension package
define php::extension (
  $ensure = 'installed',
  $provider = undef,
  $prefix = undef,
  $priority = 20,
  Hash $settings = {},
  $ext_tool_enable = $php::params::ext_tool_enable,
) {

  Exec {
    path => ['/bin', '/usr/bin','/usr/sbin']
  }

  if $provider == 'pecl' {
      $real_package = prefix([$name], "${provider}-")
      ensure_packages(['build-essential'], {'ensure' => 'present'})
  } else {
      $real_package = prefix([$name], $prefix)
  }

  if $provider {
    $deps = [Class['php::pear'], Class['php::dev']]
  }
  else {
    $deps = Class['php::packages']
  }

  package { $real_package:
    ensure   => $ensure,
    provider => $provider,
    require  => $deps,
  }

  if $provider {
    file {"${php::params::config_root}/mods-available/${name}.ini":
      content => "; Managed by puppet\n; priority=${priority}\nextension=${name}.so\n",
      notify  => Exec["enabling_${name}"],
    }

    exec { "enabling_${name}":
      cwd         => '/tmp',
      command     => "${ext_tool_enable} ${name}",
      refreshonly => true,
    }

    Package[$real_package] -> File["${php::params::config_root}/mods-available/${name}.ini"] -> Exec["enabling_${name}"]
  } else {
    exec { "enabling_${name}":
      cwd         => '/tmp',
      command     => "${ext_tool_enable} ${name}",
      refreshonly => true,
    }

    Package[$real_package] ~> Exec["enabling_${name}"]
  }

  $defaults = {
    path    => "${php::params::config_root}/mods-available/${name}.ini",
    require => Package[$real_package],
  }
  inifile::create_ini_settings({ '' => $settings }, $defaults)
}
