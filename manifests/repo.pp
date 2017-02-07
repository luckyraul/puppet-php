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
