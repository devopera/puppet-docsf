class docsf::params {

  case $operatingsystem {
    centos, redhat, fedora: {
      $lf_log_syslog = '/var/log/messages'
    }
    ubuntu, debian: {
      $lf_log_syslog = '/var/log/syslog'
    }
  }

}

