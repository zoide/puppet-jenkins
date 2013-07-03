# Class: jenkins::slave
#
#
#  ensure is not immplemented yet, since i'm
#  assuming you want to actually run the slave
#  by declaring it..
#
class jenkins::slave (
  $masterurl         = undef,
  $ui_user           = undef,
  $ui_pass           = undef,
  $labels            = undef,
  $version           = '1.9',
  $executors         = 2,
  $manage_slave_user = 1,
  $slave_user        = 'jenkins-slave',
  $slave_uid         = undef,
  $slave_home        = '/home/jenkins-slave',
  $execmode          = 'exclusive') {
  $client_jar = "swarm-client-${version}-jar-with-dependencies.jar"
  $client_url = "http://maven.jenkins-ci.org/content/repositories/releases/org/jenkins-ci/plugins/swarm-client/${version}/"

  case $::osfamily {
    'RedHat' : { $java_package = 'java-1.6.0-openjdk' }
    'Linux'  : { $java_package = 'java-1.6.0-openjdk' }
    'Debian' : { $java_package = 'openjdk-6-jdk' }

    default  : { fail("Unsupported OS family: ${::osfamily}") }
  }

  # add jenkins slave if necessary.

  if $manage_slave_user == 1 and $slave_uid {
    User['jenkins-slave_user'] {
      uid => $slave_uid }
  }

  if ($manage_slave_user == 1) {
    user { 'jenkins-slave_user':
      ensure     => present,
      name       => $slave_user,
      comment    => 'Jenkins Slave user',
      home       => $slave_home,
      managehome => true,
    }
  }

  if !defined(Package[$java_package]) {
    package { $java_package: ensure => installed; }
  }

  exec { 'get_swarm_client':
    command => "wget -O ${slave_home}/${client_jar} ${client_url}/${client_jar}",
    path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin',
    user    => $slave_user,
    # refreshonly => true,
    creates => "${slave_home}/${client_jar}"
  # # needs to be fixed if you create another version..
  }

  if $labels {
    $labels_flag = "-labels '${labels}'"
  } else {
    $labels_flag = ''
  }

  if $ui_user {
    $ui_user_flag = "-username '${ui_user}'"
  } else {
    $ui_user_flag = ''
  }

  if $ui_pass {
    $ui_pass_flag = "-password ${ui_pass}"
  } else {
    $ui_pass_flag = ''
  }

  if $masterurl {
    $masterurl_flag = "-master ${masterurl}"
  } else {
    $masterurl_flag = ''
  }
  $initscript = $::osfamily ? {
    'Debian' => template("${module_name}/jenkins-slave.Debian.erb"),
    default  => template("${module_name}/jenkins-slave.erb"),
  }

  file { '/etc/init.d/jenkins-slave':
    ensure  => 'file',
    mode    => '0700',
    owner   => 'root',
    group   => 'root',
    content => $initscript,
    notify  => Service['jenkins-slave']
  }

  service { 'jenkins-slave':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  Package[$java_package] -> Exec['get_swarm_client'] -> Service['jenkins-slave']

}
