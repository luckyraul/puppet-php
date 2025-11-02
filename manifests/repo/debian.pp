# == Class: php::repo
class php::repo::debian (
  $version      = $php::version,
  $manage_repos = $php::manage_repos,
  $mirror       = $php::repo_mirror,
  $newrelic     = $php::newrelic,
) {
  include 'apt'

  if $manage_repos {
    if ($mirror) {
      $key_name = 'mygento_php'
      $location = 'http://apt.cloud.mygento.com/php/'
      $repos    = 'php'
      $key_id    = '9098D342C5B0C20384FF65D0A2033273125F55CF'
      $key_url   = 'http://apt.cloud.mygento.com/public.asc'
    } else {
      $key = 'sury_php'
      $location = 'https://packages.sury.org/php/'
      $repos    = 'main'
      $key_id    = '15058500A0235D97F5D10063B188E2B695BD4743'
      $key_url   = 'https://packages.sury.org/php/apt.gpg'
    }
    $release = $php::params::release
    case $version {
      '7.4', '8.0', '8.1', '8.2', '8.3', '8.4', '8.5': {
        case $facts['os']['distro']['codename'] {
          'trixie': {
            file { "/etc/apt/sources.list.d/source_php_${release}.list":
              ensure => absent,
            }
            apt::keyring { "${key_name}.asc":
              source  => $key_url,
            } -> apt::source { 'php':
              enabled       => true,
              source_format => 'sources',
              location      => [$location],
              repos         => [$repos],
              architecture  => [$facts['os']['architecture']],
              keyring       => "/etc/apt/keyrings/${key_name}.asc",
            }
          }
          'bullseye', 'bookworm': {
            create_resources(::apt::key, { 'php::repo' => {
                  id => $key_id, source => $key_url, ensure => 'refreshed',
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
    case $facts['os']['distro']['codename'] {
      'bullseye', 'bookworm': {
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
      default: {
        apt::keyring { 'newrelic.asc':
          source  => 'https://download.newrelic.com/548C16BF.gpg',
        } -> apt::source { 'newrelic':
          enabled       => true,
          source_format => 'sources',
          release       => 'newrelic',
          location      => ['http://apt.newrelic.com/debian/'],
          repos         => ['non-free'],
          architecture  => [$facts['os']['architecture']],
          keyring       => '/etc/apt/keyrings/newrelic.asc',
        }
      }
    }
  }
}
