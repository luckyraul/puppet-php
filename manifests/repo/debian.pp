# == Class: php::repo
class php::repo::debian (
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
          'stretch', 'buster', 'bullseye', 'bookworm': {
            $release = $php::params::release
            $location = 'https://packages.sury.org/php/'
            $repos    = 'main'
            $key      = {
              'id'     => '15058500A0235D97F5D10063B188E2B695BD4743',
              'source' => 'https://packages.sury.org/php/apt.gpg',
            }
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

    create_resources(::apt::key, { 'php::repo' => {
          id => $key['id'], source => $key['source'], ensure => 'refreshed',
    } })

    ::apt::source { "source_php_${release}":
      location => $location,
      release  => $release,
      repos    => $repos,
      include  => {
        'src' => false,
      },
      require  => Apt::Key['php::repo'],
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
