# == Class: php::config
class php::config(
  $settings = $php::settings,
  $version  = $php::version,
  )
{
  $defaults_cli = { 'path' => "${php::params::config_root}/cli/php.ini" }
  $result_cli = deep_merge($php::params::default_config, $settings)
  create_ini_settings($result_cli, $defaults_cli)

  if($php::fpm) {
    $defaults_fpm = { 'path' => "${php::params::config_root}/fpm/php.ini" }
    $result_fpm = deep_merge($php::params::default_config, $settings)
    create_ini_settings($result_fpm, $defaults_fpm)
  }

  $defaults_opc = { 'path' => "${php::params::config_root}/mods-available/opcache.ini" }
  $result_opc = deep_merge($php::params::opc_config, $settings)
  create_ini_settings($result_opc, $defaults_opc)
}
