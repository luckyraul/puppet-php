# Class php::composer
class php::composer (
  $composer_source  = $php::params::composer_source,
  $composer_path    = $php::params::composer_path,
) {
  stdlib::ensure_packages(['curl'], { 'ensure' => 'present' })

  Package['curl'] -> archive { $composer_path:
    ensure => 'present',
    source => $composer_source,
  } -> file { $composer_path:
    mode  => '0755',
  }
}
