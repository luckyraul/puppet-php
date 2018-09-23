#
class php::globals (
  $php_version = undef
) {
  if $php_version != undef {
    validate_re($php_version, '^[57].[0-9]')
  }

  $default_php_version = $::facts['os']['release']['major'] ? {
    '9' => '7.0',
    '10' => '7.2',
    default => '5.x',
  }

  $global_php_version = pick($php_version, $default_php_version)

  Class['php::globals'] -> Class['php']
}
