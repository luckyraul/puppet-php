# Class php::newrelic
class php::newrelic (
    $ensure  = $php::newrelic,
) inherits php::params {

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
  } ->
  package { 'newrelic-php5':
    ensure  => $ensure,
  }

  Exec['apt_update'] -> Package['newrelic-php5']
}
