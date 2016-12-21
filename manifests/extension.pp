# Install a PHP extension package
define php::extension (
  $ensure = 'installed',
  $provider = undef,
  $priority = 20,
) {
  validate_string($ensure)

  Exec {
    path => ['/bin', '/usr/bin','/usr/sbin']
  }

  if $provider == 'pecl' {
      $real_package = "pecl-${name}"
  } else {
      $real_package = $name
  }

  package { $real_package:
    ensure   => $ensure,
    provider => $provider,
    require  => [
        Class['php::pear'],
        Class['php::dev'],
    ],
  }

  file {"${php::params::config_root}/mods-available/${name}.ini":
    content => "; Managed by puppet\n; priority=${priority}\nextension=${name}.so\n",
    notify  => Exec["enabling_${name}"],
  }

  exec { "enabling_${name}":
    cwd         => '/tmp',
    command     => "php5enmod ${name}",
    refreshonly => true,
  }

  Package[$real_package] -> File["${php::params::config_root}/mods-available/${name}.ini"] -> Exec["enabling_${name}"]
}
