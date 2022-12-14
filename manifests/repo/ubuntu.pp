# == Class: php::repo
class php::repo::ubuntu (
  $version      = $php::version,
  $manage_repos = $php::manage_repos,
  $newrelic     = $php::newrelic,
) {
  # validate_string($version)

  include 'apt'

  if $manage_repos {
    case $version {
      '7.4', '8.0', '8.1', '8.2': {
        case $facts['os']['distro']['codename'] {
          'bionic', 'focal', 'jammy': {
            ::apt::ppa { 'ppa:ondrej/php': }
            ensure_packages(['apt-transport-https'], { 'ensure' => 'present' })
          }
          default: {
            fail("Unsupported PHP release: ${facts['os']['distro']['codename']} - ${version}")
          }
        }
      }
      default: {
        fail("Unsupported PHP release: ${version}")
      }
    }
  }

  if $newrelic {
    apt::source { 'newrelic':
      location => 'http://apt.newrelic.com/debian/',
      repos    => 'non-free',
      key      => {
        id  => 'B60A3EC9BC013B9C23790EC8B31B29E5548C16BF',
        key => 'https://download.newrelic.com/548C16BF.gpg',
      },
      include  => {
        src => false,
      },
      release  => 'newrelic',
    }
  }
}
