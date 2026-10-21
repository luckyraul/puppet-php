# Manage fpm service
# === Parameters
# [*version*]
#   Version of packages
# [*ensure*]
#   Status of service
# [*enable*]
#   Status of service
# [*other_versions*]
#   Version of packages
# [*settings*]
#   Service settings
# [*config_root*]
#   Config root
#
class php::fpm::service (
  Enum['running', 'stopped'] $ensure = $php::fpm_service_ensure,
  Boolean $enable = $php::fpm_service_enable,
  String[1] $version = $php::version,
  Array[String[1]] $other_versions = $php::multi_version,
  Hash $settings = $php::fpm_service_settings,
  String[1] $config_root = $php::params::config_root,
) {
  assert_private()
  unique(concat($other_versions, $version)).each |String $value| {
    $config = deep_merge(
      $php::params::fpm_service_settings,
      php::fpm_settings($value),
      $settings
    )

    file { $config['file']:
      ensure  => file,
      mode    => '0644',
      owner   => root,
      group   => root,
      notify  => Service["php${value}-fpm"],
      content => template('php/fpm/php-fpm.conf.erb'),
    }

    service { "php${value}-fpm":
      ensure     => $ensure,
      enable     => $enable,
      hasrestart => true,
      hasstatus  => true,
    }
  }
}
