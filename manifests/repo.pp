# == Class: php::repo
class php::repo
{
  case $::operatingsystem {
      'Debian': {
        include ::php::repo::debian
      }
      'Ubuntu': {
        include ::php::repo::ubuntu
      }
      default: {
          fail("Unsupported os: ${::operatingsystem}")
      }
  }
}
