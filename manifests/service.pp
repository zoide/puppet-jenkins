class jenkins::service {
  include 'jenkins::params'

  if !defined(Service[$jenkins::params::service]) {
    service { $jenkins::params::service:
      ensure     => running,
      enable     => true,
      hasstatus  => true,
      hasrestart => true,
    }
  }

}

