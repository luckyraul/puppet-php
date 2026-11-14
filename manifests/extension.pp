# Install a PHP extension package
# [*ensure*]
#   The ensure of the package to install
#   Could be "present", "absent", "latest", "installed" or a pinned version
# [*provider*]
#   The provider used to install the package
#   Could be "pecl", "apt", "dpkg" or any other OS package provider
# [*prefix*]
# [*priority*]
# Extensions sort order
# [*settings*]
#   Hash of parameters for the specific extension, which will be written to the extensions config
# [*ext_tool_enable*]
#  
define php::extension (
  String $ensure = $php::package_ensure,
  Optional[Php::Provider] $provider = undef,
  Optional[String] $prefix = undef,
  Integer $priority = 20,
  Hash $settings = {},
  Optional[String] $ext_tool_enable = $php::params::ext_tool_enable,
) {
  Exec {
    path => ['/bin', '/usr/bin','/usr/sbin'],
  }

  if $provider == 'pecl' {
    $real_package = prefix([$name], "${provider}-")
    stdlib::ensure_packages(['build-essential'], { 'ensure' => 'present' })
  } else {
    $real_package = prefix([$name], $prefix)
  }

  package { $real_package:
    ensure   => $ensure,
    provider => $provider,
  }

  if $provider {
    file { "${php::params::config_root}/mods-available/${name}.ini":
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
