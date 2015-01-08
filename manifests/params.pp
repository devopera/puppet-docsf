class docsf::params {

  case $operatingsystem {
    centos, redhat, fedora: {
      $lf_log_syslog = '/var/log/messages'
    }
    ubuntu, debian: {
      $lf_log_syslog = '/var/log/syslog'
    }
  }

  $partial_tcp_in = '/etc/csf/csf_partial_tcp_in.conf'

}

