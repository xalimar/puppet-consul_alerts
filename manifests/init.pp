# == Class: consul_alerts
#
# The consul_alerts class currently contains installation and configuration for the consul_alerts
# puppet module. This will install a binary release of the consul-alerts service and
# launch it with upstart init system.
#
# === Parameters
#
# [*enabled*]
#   Enable the class as installed or not
#   Can be true or false (bool)
# [*binary_path*]
#   The system path in which to install the consul-alerts binary download
# [*version*]
#   A string containing the release version to install
# [*repo_url*]
#   Default repository URL from which to download the binary release
# [*default_url*]
#   Use the default repository and download url either true or false (bool)
# [*custom_url*]
#   If you want to specify a custom download filename/location, specify it here
# [*alert_addr*]
#   Location to run the consul-alert service API on. Defaults to 127.0.0.1:9000
# [*consul_url*]
#   URL for the consul instance you want to use with alerts service
# [*data_center*]
#   Specify the data-center name in which to run the consul-alerts checks and k/v lookups
# [*watch_events*]
#   Boolean value for if event notifications from consul should be watched
# [*watch_checks*]
#   Boolean value for check update notifications from consul
#
# === Examples
#
#  class { 'consul_alerts':
#    consul_url  => '127.0.0.1:8500',
#    data_center => 'dc1',
#  }
#
# === Authors
#
# Justice London <jlondon@syrussystems.com>
#
# === Copyright
#
# Copyright 2015 Justice London
#
class consul_alerts (
  $enabled      = true,
  $binary_path  = '/usr/local/bin',
  $version      = '0.5.0',
  $repo_url     = 'https://github.com/AcalephStorage/consul-alerts/releases/download',
  $alert_addr   = '127.0.0.1:9000',
  $consul_url   = '127.0.0.1:8500',
  $data_center  = 'dc1',
  $watch_events = true,
  $watch_checks = true,
  $user         = 'consul',
  $group        = 'consul',
) {
  validate_bool($enabled)
  validate_bool($watch_events)
  validate_bool($watch_checks)
  validate_absolute_path($binary_path)
  validate_string($version)
  validate_string($repo_url)
  validate_string($alert_addr)
  validate_string($consul_url)
  validate_string($data_center)
  validate_string($user)
  validate_string($group)

  $filename = "consul-alerts-${version}-linux-amd64.tar"
  $download_url = "${repo_url}/v${version}/${filename}"
  include ::archive

  archive { $filename:
    path         => "/tmp/${filename}",
    extract      => true,
    extract_path => $binary_path,
    source       => $download_url,
    creates      => "${binary_path}/consul-alerts",
    cleanup      => true,
    notify       => Service['consul-alerts.service'],
  }

  #Define present/absent as true/false. Still don't understand why this isn't a builtin.
  $file_ensure = $enabled ? {
    false   => absent,
    default => present,
  }

  file { '/etc/systemd/system/consul-alerts.service':
    ensure  => $file_ensure,
    content => template('consul_alerts/initfile.erb'),
    notify  => Service['consul-alerts.service'],
  }

  service { 'consul-alerts.service':
    ensure => $enabled,
    enable => $enabled,
  }
}
