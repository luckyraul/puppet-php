#
class php::packages (
    $ensure         = $php::ensure,
    $manage_repos   = $php::manage_repos,
    $common_names   = $php::params::common_package,
    $packages_names = $php::packages,
) inherits php::params {
    validate_string($ensure)
    validate_array($common_names)
    validate_array($packages_names)

    $merge_names = union($packages_names, $common_names)
    $package_list = prefix($merge_names, $php::params::package_prefix)

    if $manage_repos {
      Exec['apt_update'] -> Package[$package_list]
    }

    package { $package_list:
        ensure => $ensure,
    }
}
