#
define jenkins::plugin (
  $version = 0,
  $user    = $jenkins::params::user,
  $group   = $jenkins::params::group,
  $service = $jenkins::params::service) {
  $plugin = "${name}.hpi"
  $plugin_dir = '/var/lib/jenkins/plugins'
  $plugin_parent_dir = '/var/lib/jenkins'
  include 'jenkins::params'

  if ($version != 0) {
    $base_url = "http://updates.jenkins-ci.org/download/plugins/${name}/${version}/"
  } else {
    $base_url = 'http://updates.jenkins-ci.org/latest/'
  }

  if (!defined(File[$plugin_dir])) {
    file { [$plugin_parent_dir, $plugin_dir]:
      ensure  => directory,
      owner   => $user,
      group   => $group,
     # require => [Group[$group], User[$user]];
    }
  }

#  if (!defined(Group[$group])) {
#    group { $group: ensure => present; }
#  }
#
#  if (!defined(User[$user])) {
#    user { $user: ensure => present; }
#  }

  exec { "download-${name}":
    command => "wget --no-check-certificate ${base_url}${plugin}",
    cwd     => $plugin_dir,
    require => File[$plugin_dir],
    path    => ['/usr/bin', '/usr/sbin',],
    unless  => "test -f ${plugin_dir}/${plugin}",
  }

  file { "${plugin_dir}/${plugin}":
    require => Exec["download-${name}"],
    owner   => $user,
    mode    => '0644',
    notify  => Service[$service]
  }
}
