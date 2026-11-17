# @summary Installs s6-overlay for AMD64 and ARM64 Linux systems.
#
# Downloads and extracts the appropriate s6-overlay release based on
# the system architecture detected by Facter.
#
# Only AMD64 (x86_64) and ARM64 (aarch64) are supported.
#
# @param version
#   PHP Version
# @param s6version
#   Version of s6-overlay to install.
# @param install_dir
#   Directory used to store the downloaded archive.
# @param run_as_root
#   Run services as root and drop privileges to www-data.
#   When false, services run as the current container user.
class php::overlay (
  String[1] $version = $php::version,
  String $s6version = '3.2.3.2',
  String $install_dir = '/tmp/s6-overlay',
  Boolean $run_as_root = false,
) {
  $architecture = $facts['os']['architecture']

  $arch_map = {
    'x86_64'  => 'x86_64',
    'amd64'   => 'x86_64',
    'aarch64' => 'aarch64',
    'arm64'   => 'aarch64',
  }

  if $architecture in $arch_map {
    $s6_arch = $arch_map[$architecture]
  } else {
    fail("Unsupported architecture: ${architecture}. Only AMD64 and ARM64 are supported.")
  }

  Package['curl'] -> Archive['s6-overlay-noarch']
  Package['tar'] -> Archive['s6-overlay-noarch']
  Package['xz-utils'] -> Archive['s6-overlay-noarch']

  package { ['curl', 'tar', 'xz-utils']:
    ensure => present,
  }

  $base_url = "https://github.com/just-containers/s6-overlay/releases/download/v${s6version}"

  archive { 's6-overlay-noarch':
    ensure       => present,
    url          => "${base_url}/s6-overlay-noarch.tar.xz",
    path         => "${install_dir}/s6-overlay-noarch.tar.xz",
    extract      => true,
    extract_path => '/',
    creates      => '/init',
  } -> file { '/init':
    mode => '0755',
  }

  archive { 's6-overlay-arch':
    ensure       => present,
    url          => "${base_url}/s6-overlay-${s6_arch}.tar.xz",
    path         => "${install_dir}/s6-overlay-${s6_arch}.tar.xz",
    extract      => true,
    extract_path => '/',
    creates      => '/command/s6-svscan',
    require      => Archive['s6-overlay-noarch'],
  }

  $s6_directory = '/etc/s6-overlay/user-bundles.d'

  file { $s6_directory:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { "${s6_directory}/user":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File[$s6_directory],
  }

  file { "${s6_directory}/user/contents.d":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File["${s6_directory}/user"],
  }

  # Select service execution mode.
  #
  # Root mode:
  #   s6-setuidgid switches to www-data.
  #
  # Non-root mode:
  #   Execute directly as the current container user.
  if $run_as_root {
    $php_run = @("SCRIPT"/L)
      #!/command/with-contenv bash
      exec s6-setuidgid www-data php-fpm${version} -F
      | SCRIPT

    $nginx_run = @("SCRIPT"/L)
      #!/command/with-contenv bash
      exec s6-setuidgid www-data nginx
      | SCRIPT
  } else {
    $php_run = @("SCRIPT"/L)
      #!/command/with-contenv bash
      exec php-fpm${version} -F
      | SCRIPT

    $nginx_run = @("SCRIPT"/L)
      #!/command/with-contenv bash
      exec nginx
      | SCRIPT
  }

  $services = [
    {
      name => 'php-fpm',
      type => 'longrun',
      run  => $php_run,
    },
    {
      name => 'nginx',
      type => 'longrun',
      run  => $nginx_run,
    },
  ]

  $services.each |Hash $service| {
    $service_directory = "${s6_directory}/${service['name']}"

    file { $service_directory:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File[$s6_directory],
    }

    file { "${service_directory}/type":
      ensure  => file,
      content => "${service['type']}\n",
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File[$service_directory],
    }

    file { "${service_directory}/run":
      ensure  => file,
      content => $service['run'],
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => File[$service_directory],
    }

    file { "${s6_directory}/user/contents.d/${service['name']}":
      ensure  => file,
      content => '',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File["${s6_directory}/user/contents.d"],
    }
  }
}
