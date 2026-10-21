# Install docker entrypoint
#
class php::docker {
  assert_private()
  file { '/entrypoint.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('php/docker/entrypoint.epp'),
  }

  file { '/var/www':
    ensure => directory,
    owner  => www-data,
    group  => www-data,
  }
}
