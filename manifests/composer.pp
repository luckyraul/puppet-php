# Class php::composer
class php::composer (
  $composer_source  = $php::params::composer_source,
  $composer_path    = $php::params::composer_path,
) {

  ensure_packages(['curl'], {'ensure' => 'present'})

  include ::staging

  Package['curl'] -> staging::file { 'composer.phar':
    source => $composer_source,
  } -> file { $composer_path:
      ensure  => 'present',
      mode    => '0550',
      source  => "${::staging::path}/php/composer.phar",
  }
}
