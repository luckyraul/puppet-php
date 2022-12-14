#
class php::globals (
  $php_version = undef
) {
  $default_php_version = $::facts['os']['release']['major'] ? {
    '9' => '7.0',
    '10' => '7.3',
    '11' => '7.4',
    '12' => '8.1',
    default => '7.4',
  }

  $global_php_version = pick($php_version, $default_php_version)

  Class['php::globals'] -> Class['php']
}
