# PHP class
#
# === Parameters
#
# [*version*]
#   Status of packages
# [*package_ensure*]
#   Status of packages
# [*packages*]
#   List of packages to install
# [*fpm*]
#   Install and configure php-fpm
# [*fpm_service_enable*]
#   Enable/disable FPM service
# [*fpm_service_ensure*]
#   Ensure FPM service is either 'running' or 'stopped'
# [*fpm_pools*]
#   Hash of php::fpm::pool resources that will be created. Defaults
#   to a single php::fpm::pool named www with default parameters.
# [*fpm_service_settings*]
#   Fpm Service Settings
# [*composer*]
#   Install composer flag.
# [*repo_mirror*]
#   Install repo mirror flag.
# [*newrelic*]
#   Install newrelic flag.
# [*newrelic_settings*]
#   Install newrelic flag.
# [*newrelic_configfile*]
#   Newrelic ini file path.
# [*manage_repos*]
#   Install from external repository.
# [*package_prefix*]
#   This is the prefix for constructing names of php packages. This defaults
#   to a sensible default depending on your operating system, like 'php-' or
#   'php8-'.
# [*multi_version*]
#   Install additional versions.
# [*docker*]
#   Docker Entrypoint
#
class php (
  Enum['absent', 'present', 'latest'] $package_ensure = 'present',
  String[1] $version = $php::params::php_version,
  Array[String] $packages = [],
  Boolean $composer = true,
  Boolean $repo_mirror = false,
  Boolean $newrelic = false,
  Boolean $manage_repos = $php::params::manage_repos,
  Boolean $fpm = true,
  Boolean $fpm_service_enable = true,
  Boolean $docker = false,
  Hash $newrelic_settings    = $php::params::newrelic_settings,
  String[1] $newrelic_configfile  = $php::params::newrelic_configfile,
  Enum['running', 'stopped'] $fpm_service_ensure = 'running',
  Hash $fpm_pools = $php::params::fpm_pools,
  Hash $fpm_service_settings = {},
  Optional[String[1]] $package_prefix = $php::params::package_prefix,
  Array[String[1]] $multi_version = [],
) inherits php::params {
  contain php::repo
  contain php::packages
  if $fpm { contain 'php::fpm' }

  if $composer { contain 'php::composer' }

  if $newrelic and $::facts['os']['architecture'] == 'amd64' {
    Class['php::packages'] -> class { 'php::newrelic': }
  }

  if $docker { contain 'php::docker' }
}
