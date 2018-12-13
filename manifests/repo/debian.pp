# == Class: php::repo
class php::repo::debian(
        $version      = $php::version,
        $manage_repos = $php::manage_repos,
        $newrelic     = $php::newrelic,
    )
{

    validate_string($version)

    include '::apt'

    if $manage_repos {

      case $version {
          '5.6': {
              case $::lsbdistcodename {
                  'wheezy': {
                      $release  = "${::lsbdistcodename}-php56"
                      $repos    = 'all'
                      $location = 'http://packages.dotdeb.org'
                      $key      = {
                          'id'     => '6572BBEF1B5FF28B28B706837E3F070089DF5277',
                          'source' => 'http://www.dotdeb.org/dotdeb.gpg',
                      }
                  }
                  default: {
                      fail("Unsupported PHP release: ${::lsbdistcodename} - ${version}")
                  }
              }
          }
          '7.0': {
              case $::lsbdistcodename {
                  'jessie': {
                      $release = $php::params::release
                      $repos    = 'all'
                      $location = 'http://packages.dotdeb.org'
                      $key      = {
                          'id'     => '6572BBEF1B5FF28B28B706837E3F070089DF5277',
                          'source' => 'http://www.dotdeb.org/dotdeb.gpg',
                      }
                  }
                  'stretch': {

                  }
                  default: {
                      fail("Unsupported PHP release: ${::lsbdistcodename} - ${version}")
                  }
              }
          }
          '7.1', '7.2', '7.3': {
              case $::lsbdistcodename {
                  'jessie', 'stretch': {
                      $release = $php::params::release
                      $location = 'https://packages.sury.org/php/'
                      $repos    = 'main'
                      $key      = {
                          'id'     => 'DF3D585DB8F0EB658690A554AC0E47584A7A714D',
                          'source' => 'https://packages.sury.org/php/apt.gpg',
                      }
                      ensure_packages(['apt-transport-https'], {'ensure' => 'present'})
                  }
                  default: {
                      fail("Unsupported PHP release: ${::lsbdistcodename} - ${version}")
                  }
              }
          }
          default: {
              fail("Unsupported PHP release: ${version}")
          }
      }

      create_resources(::apt::key, { 'php::repo' => {
          id => $key['id'], source => $key['source'],
      }})

      ::apt::source { "source_php_${release}":
          location => $location,
          release  => $release,
          repos    => $repos,
          include  => {
            'src' => false
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