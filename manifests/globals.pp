# PHP globals class
#
# === Parameters
#
# [*php_version*]
#   The version of php.
#
class php::globals (
  Optional[Pattern[/^(rh-)?(php)?[78](\.)?[0-9]/]] $php_version = undef,
) {
  if ($php_version == undef) {
    $globals_php_version = $facts['os']['name'] ? {
      'Debian' => $facts['os']['release']['major'] ? {
        '12'    => '8.2',
        '13'    => '8.4',
        '14'    => '8.4',
        default => fail("Unsupported Debian release: ${fact('os.release.major')}"),
      },
      'Ubuntu' => $facts['os']['release']['major'] ? {
        '24.04' => '8.3',
        '26.04' => '8.5',
        default => fail("Unsupported Ubuntu release: ${fact('os.release.major')}"),
      },
      default => fail("Unsupported release: ${fact('os.release.major')}"),
    }
  } else {
    $globals_php_version = $php_version
  }

  $package_prefix = "php${globals_php_version}-"
}
