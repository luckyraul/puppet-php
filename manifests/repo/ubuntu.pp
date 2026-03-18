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
      '7.4', '8.0', '8.1', '8.2', '8.3', '8.4', '8.5': {
        case $facts['os']['distro']['codename'] {
          'focal', 'jammy', 'noble': {
            ::apt::ppa { 'ppa:ondrej/php': }
            stdlib::ensure_packages(['apt-transport-https'], { 'ensure' => 'present' })
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
        id  => '2EA7DB7738A22D92945E8EC732FA4C172DAD550E',
        key => 'https://download.newrelic.com/NEWRELIC_APT_2DAD550E.public',
      },
      include  => {
        src => false,
      },
      release  => 'newrelic',
    }
  }
}
