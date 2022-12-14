# == Class: php::repo
class php::repo {
  case $facts['os']['name'] {
    'Debian': {
      include php::repo::debian
    }
    'Ubuntu': {
      include php::repo::ubuntu
    }
    default: {
      fail("Unsupported os: ${facts['os']['name']}")
    }
  }
}
