# == Class: php::repo
class php::repo(
        $version  = $php::version,
        $repos    = 'all',
        $location = 'http://packages.dotdeb.org',
        $key      = {
            'id'     => '6572BBEF1B5FF28B28B706837E3F070089DF5277',
            'source' => 'http://www.dotdeb.org/dotdeb.gpg',
        }
    )
{

    validate_string($version)

    include '::apt'
    create_resources(::apt::key, { 'php::repo' => {
        key => $key['id'], key_source => $key['source'],
    }})

    case $version {
        '5.5': {
            case $::lsbdistcodename {
                'wheezy': {
                    $release = $php::params::release
                }
                'jessie': {
                    $release = 'wheezy-php55'
                    $merge_names = union($php::packages, $php::params::common_package)
                    $package_list = prefix($merge_names, $php::params::package_prefix)

                    ::apt::source { 'oldstable':
                        location => 'http://httpredir.debian.org/debian/',
                        release  => 'wheezy',
                        repos    => 'main contrib',
                        include  => {
                           'src' => false,
                        },
                        require  => Apt::Key['php::repo'],
                    }
                    apt::pin { 'downgrade_php':
                      ensure   => 'present',
                      packages => [$package_list],
                      priority => 500,
                      release  => $release,
                    }
                }
                default: {
                    fail("Unsupported PHP release: ${::lsbdistcodename} - ${version}")
                }
            }
        }
        '5.6': {
            case $::lsbdistcodename {
                'wheezy': {
                    $release = "${::lsbdistcodename}-php56"
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
