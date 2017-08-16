#
class php::globals (
  $php_version = undef
) {
  if $php_version != undef {
    validate_re($php_version, '^[57].[0-9]')
  }

  $default_php_version = $::facts['os']['release']['major'] ? {
        9 => '7.0',
        default => '5.x',
  }

  $global_php_version = pick($php_version, $default_php_version)


  # for debug output on the puppet client
  notify {"PHP version: ${::global_php_version} with ${::operatingsystemrelease}":}

  Class['php::globals'] -> Class['php']
}
