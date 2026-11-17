# @summary Installs and configures PHP, PHP-FPM, extensions and Composer.
#
# This class manages PHP packages and optional components, including
# PHP-FPM, Composer, New Relic integration and external package repositories.
#
# It supports configurable package naming, multiple PHP versions,
# custom PHP-FPM pools and Docker-oriented configurations.
#
# === Parameters
#
# @param package_ensure
#   Desired state of PHP packages.
#   Supported values are `present`, `absent` and `latest`.
#   Defaults to `present`.
#
# @param version
#   PHP version to install.
#   Defaults to the version defined by `php::params::php_version`.
#
# @param packages
#   Additional PHP packages to install.
#   Package names must match the package naming conventions of the
#   configured operating system and package repository.
#   Defaults to an empty array.
#
# @param composer
#   Whether to install Composer, the PHP dependency manager.
#   Defaults to `true`.
#
# @param repo_mirror
#   Whether to use the configured package repository mirror.
#   Defaults to `false`.
#
# @param newrelic
#   Whether to install and configure the New Relic PHP agent.
#   Defaults to `false`.
#
# @param newrelic_settings
#   Hash of New Relic configuration settings.
#   Defaults to `php::params::newrelic_settings`.
#
# @param newrelic_configfile
#   Absolute path to the New Relic PHP configuration file.
#   Defaults to `php::params::newrelic_configfile`.
#
# @param manage_repos
#   Whether this module manages the external package repositories
#   required to install PHP.
#   Defaults to `php::params::manage_repos`.
#
# @param fpm
#   Whether to install and configure PHP-FPM.
#   Defaults to `true`.
#
# @param fpm_service_enable
#   Whether the PHP-FPM service should be enabled at system startup.
#   Defaults to `true`.
#
# @param fpm_service_ensure
#   Desired runtime state of the PHP-FPM service.
#   Supported values are `running` and `stopped`.
#   Defaults to `running`.
#
# @param fpm_pool_chmod
#   Desired chmod for php-fpm pool file.
#   Defaults to `0640`.
#
# @param fpm_pools
#   Hash of PHP-FPM pool definitions.
#   Each entry describes a PHP-FPM pool to manage.
#   Defaults to the value defined by `php::params::fpm_pools`,
#   typically containing a single `www` pool.
#
# @param fpm_service_settings
#   Hash of additional PHP-FPM service configuration settings.
#   Defaults to an empty hash.
#
# @param extensions
#   Hash of PHP extensions to install and configure.
#   Extension names and values depend on the implementation of
#   the corresponding extension resources.
#   Defaults to an empty hash.
#
# @param package_prefix
#   Prefix used when constructing PHP package names.
#   This allows package naming conventions to vary between
#   operating systems and PHP versions.
#   Defaults to `php::params::package_prefix`.
#
# @param multi_version
#   Array of additional PHP versions to install alongside the
#   primary PHP version.
#   Defaults to an empty array.
#
# @param docker
#   Whether to enable Docker-specific PHP configuration.
#   Defaults to `false`.
#
# @param docker_combo
#   Whether to enable the combined Docker configuration.
#   The exact behavior depends on the module's Docker implementation.
#   Defaults to `false`.
#
# === Examples
#
# @example Default installation
#   include php
#
# @example Install PHP with additional extensions
#   class { 'php':
#     version    => '8.3',
#     extensions => {
#       'curl' => {},
#       'gd'   => {},
#       'intl' => {},
#       'redis' => {},
#     },
#   }
#
# @example Install PHP-FPM with custom pools
#   class { 'php':
#     version    => '8.3',
#     fpm        => true,
#     fpm_pools  => {
#       'www' => {
#         'listen' => '/run/php/php-fpm.sock',
#       },
#       'application' => {
#         'listen' => '/run/php/application.sock',
#       },
#     },
#   }
#
# @example Install PHP without Composer
#   class { 'php':
#     composer      => false,
#     package_ensure => 'present',
#   }
#
# @example Install multiple PHP versions
#   class { 'php':
#     version       => '8.3',
#     multi_version => ['8.2', '8.1'],
#   }
#
# @example Configure New Relic
#   class { 'php':
#     newrelic          => true,
#     newrelic_settings => {
#       'license_key' => 'YOUR_LICENSE_KEY',
#     },
#   }
#
class php (
  Enum['absent', 'present', 'latest'] $package_ensure = 'present',
  String[1] $version = $php::params::php_version,
  Array[String] $packages = [],
  Boolean $composer = true,
  Boolean $repo_mirror = false,
  Boolean $newrelic = false,
  Boolean $manage_repos = $php::params::manage_repos,
  Boolean $fpm = true,
  Boolean $fpm_service_enable = true,
  String[4] $fpm_pool_chmod = $php::params::fpm_pool_chmod,
  Boolean $docker = false,
  Boolean $docker_combo = false,
  Hash $newrelic_settings    = $php::params::newrelic_settings,
  String[1] $newrelic_configfile  = $php::params::newrelic_configfile,
  Enum['running', 'stopped'] $fpm_service_ensure = 'running',
  Hash $fpm_pools = $php::params::fpm_pools,
  Hash $fpm_service_settings = {},
  Hash $extensions           = {},
  Optional[String[1]] $package_prefix = $php::params::package_prefix,
  Array[String[1]] $multi_version = [],
) inherits php::params {
  contain php::repo
  contain php::packages
  if $fpm { contain 'php::fpm' }

  if $composer { contain 'php::composer' }

  if $newrelic and $::facts['os']['architecture'] == 'amd64' {
    Class['php::packages'] -> class { 'php::newrelic': }
  }

  create_resources('php::extension', $extensions,
    {
      require => Class['php::packages'],
    },
  )

  if $docker { contain 'php::docker' }
  if $docker_combo { contain 'php::overlay' }
}
