class php::globals (
$php_version = undef
) {
  if $php_version != undef {
    validate_re($php_version, '^[57].[0-9]')
  }

  $default_php_version = $::operatingsystemrelease ? {
        9 => '7.0',
        default => '5.x',
  }

  $global_php_version = pick($php_version, $default_php_version)

  Class['php::globals'] -> Class['php']
}
