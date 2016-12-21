# Class php::pear
class php::pear (
  $ensure = $php::ensure
)
{
  package { 'php-pear':
    ensure  => $ensure,
    require => Class['php::packages'],
  }
}
