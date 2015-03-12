class docsf::params {

  case $operatingsystem {
    centos, redhat, fedora: {
      $lf_log_syslog = '/var/log/messages'
    }
    ubuntu, debian: {
      $lf_log_syslog = '/var/log/syslog'
    }
  }

  $tmp_dir = '/etc/puppet/tmp'

  # use notifier dir as /etc/csf may not exist yet
  $partial_tcp_in = "${tmp_dir}/csf_partial_tcp_in.conf"

}

