function php::fpm_settings(String $version) >> Hash {
  $fpm_pid_file = "/run/php/php${version}-fpm.pid"
  $fpm_error_log = "/var/log/php${version}-fpm.log"
  $config_root = "/etc/php/${version}"
  $fpm_pool_dir = "${config_root}/fpm/pool.d/"

  $config = {
    file => "${config_root}/fpm/php-fpm.conf",
    pool_base_dir => $fpm_pool_dir,
    pid_file => $fpm_pid_file,
    error_log => $fpm_error_log,
  }
}
