#
class php::packages (
  $ensure         = $php::ensure,
  $manage_repos   = $php::manage_repos,
  $common_names   = $php::params::common_package,
  $packages_names = $php::packages,
  $version        = $php::version,
  $other_versions = $php::multi_version,
) inherits php::params {
  # validate_string($ensure)
  # validate_array($common_names)
  # validate_array($packages_names)

  $common_list = prefix($common_names, $php::params::package_prefix)
  $package_list = prefix($packages_names, $php::params::package_prefix)

  stdlib::ensure_packages(['unzip'], { 'ensure' => 'present' })

  package { $common_list:
    ensure => $ensure,
  } -> package { $package_list:
    ensure => $ensure,
  }

  $other_versions.each |String $version| {
    $cl = prefix($common_names, "php${version}-")
    $pl = prefix($packages_names, "php${version}-")
    package { $cl:
      ensure => $ensure,
    } -> package { $pl:
      ensure => $ensure,
    }
  }
}
