# Configure ubuntu apt repo
#
# === Parameters
#
# [*manage_repos*]
#   Location of the apt repository
#
# [*mirror*]
#   Apt repository names
#
# [*newrelic*]
#   Add source source repository
#
class php::repo::ubuntu (
  Boolean $manage_repos = $php::manage_repos,
  Boolean $mirror       = $php::repo_mirror,
  Boolean $newrelic     = $php::newrelic,
) {
  assert_private()
  include 'apt'

  if $manage_repos {
    apt::keyring { 'php-sury.gpg':
      source => 'https://packages.sury.org/php/apt.gpg',
    } -> apt::source { 'php-sury':
      source_format => 'sources',
      location      => ['https://packages.sury.org/php/'],
      repos         => ['main'],
      keyring       => '/etc/apt/keyrings/php-sury.gpg',
    }
  } else {
    apt::keyring { 'php-sury':
      ensure => 'absent',
    }
    apt::source { 'php-sury':
      ensure => 'absent',
    }
  }

  if $newrelic {
    apt::keyring { 'newrelic.asc':
      source => 'https://download.newrelic.com/NEWRELIC_APT_2DAD550E.public',
    } -> apt::source { 'newrelic':
      source_format => 'sources',
      location      => ['http://apt.newrelic.com/debian/'],
      release       => 'newrelic',
      repos         => ['non-free'],
      keyring       => '/etc/apt/keyrings/newrelic.asc',
    }
  } else {
    apt::keyring { 'newrelic':
      ensure => 'absent',
    }
    apt::source { 'newrelic':
      ensure => 'absent',
    }
  }
}
