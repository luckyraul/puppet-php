# == Class: php::config
class php::config (
  $settings = $php::settings,
  $version  = $php::version,
  $other_versions = $php::multi_version
) {
  unique(concat($other_versions, $version)).each |String $value| {
    $config_root = "/etc/php/${value}"

    $defaults_cli = { 'path' => "${config_root}/cli/php.ini", require => Class['php::packages'] }
    $result_cli = deep_merge($php::params::default_config, $settings)
    inifile::create_ini_settings($result_cli, $defaults_cli)

    if ($php::fpm) {
      $defaults_fpm = { 'path' => "${config_root}/fpm/php.ini", require => Class['php::fpm'] }
      $result_fpm = deep_merge($php::params::default_config, $settings)
      inifile::create_ini_settings($result_fpm, $defaults_fpm)
    }

    $defaults_opc = { 'path' => "${config_root}/mods-available/opcache.ini", require => Class['php::packages'] }
    $result_opc = deep_merge($php::params::opc_config, $settings)
    inifile::create_ini_settings($result_opc, $defaults_opc)
  }
}
