# Install common PHP packages
#
# === Parameters
# [*ensure*]
#   Status of packages
# [*manage_repos*]
#   Include external repository to install recent PHP from
# [*newrelic*]
#   Include newrelic repository to install
# [*packages_names*]
#   Install additional packages.
# [*other_versions*]
#   Install additional versions.
#
class php::packages (
  Enum['absent', 'present', 'latest'] $ensure = $php::package_ensure,
  Boolean $manage_repos  = $php::manage_repos,
  Boolean $newrelic  = $php::newrelic,
  Array[String] $packages_names = $php::packages,
  Array[String] $other_versions = $php::multi_version,
) inherits php::params {
  assert_private()

  $common_list = prefix($php::params::common_packages, $php::params::package_prefix)
  $package_list = prefix($packages_names, $php::params::package_prefix)
  if $facts['os']['family'] == 'Debian' {
    if $manage_repos or $newrelic {
      include apt
      Class['apt::update'] -> Package[$common_list]
    }
  }

  package { $common_list:
    ensure => $ensure,
  } -> package { $package_list:
    ensure => $ensure,
  }

  $other_versions.each |String $version| {
    $cl = prefix($php::params::common_packages, "php${version}-")
    $pl = prefix($packages_names, "php${version}-")
    Package[$common_list] -> Package[$cl]
    package { $cl:
      ensure => $ensure,
    } -> package { $pl:
      ensure => $ensure,
    }
  }
}
