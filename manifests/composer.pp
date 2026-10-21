# Install composer package manager
#
# === Parameters
#
# [*source*]
#   Holds URL to the Composer source file
#
# [*path*]
#   Holds path to the Composer executable
#
class php::composer (
  String $source                       = $php::params::composer_source,
  Stdlib::Absolutepath $path           = $php::params::composer_path,
) {
  assert_private()

  archive { 'download composer':
    path   => $path,
    source => $source,
  } -> file { $path:
    mode  => '0755',
    owner => root,
  }
}
