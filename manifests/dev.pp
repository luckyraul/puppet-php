# Class php::dev
class php::dev (
  $ensure = $php::ensure,
  $version = $php::version,
  $other_versions = $php::multi_version
) {
  unique(concat($other_versions, $version)).each |String $value| {
    package { "php${value}-${php::params::dev_package}":
      ensure  => $ensure,
      require => Class['php::packages'],
      #install_options => ['--no-install-recommends'],
    }
  }
}
