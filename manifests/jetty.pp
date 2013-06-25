class jenkins::jetty (
  $ensure = 'present') inherits jenkins::params {
  if !defined(Class['jetty']) {
    err("${hostname} also must use Class[jetty]")
  }

  Jenkins::Params {
    user    => 'jetty',
    group   => 'jetty',
    service => 'jetty'
  }

  # http://mirrors.jenkins-ci.org/war/latest/jenkins.war
  # download and install
#  if $ensure == 'present' {
#    file { '/usr/share/jetty/.jenkins': ensure => '/var/lib/jenkins', }
#  }
}