class docsf::params {

  case $operatingsystem {
    centos, redhat, fedora: {
      case $::operatingsystemmajrelease {
        '7', default: {
          $lf_log_syslog = '/var/log/messages'
          $service_path = '/etc/init:/etc/init.d:/usr/lib/systemd/system'
          $service_provider = 'systemd'
          $systemctl = '/bin/systemctl'
        }
        '6': {
          $lf_log_syslog = '/var/log/messages'
          $service_path = '/etc/init:/etc/init.d'
          $service_provider = undef
          $systemctl = ''
        }
      }
    }
    ubuntu, debian: {
      case $::operatingsystemmajrelease {
        '16.04', default: {
          $lf_log_syslog = '/var/log/syslog'
          $service_path = '/etc/init:/etc/init.d:/usr/lib/systemd/system'
          $service_provider = 'systemd'
          $systemctl = '/bin/systemctl'
        }
        '12.04','13.04','14.04','15.04': {
          $lf_log_syslog = '/var/log/syslog'
          $service_path = '/etc/init:/etc/init.d'
          $service_provider = 'upstart'
          $systemctl = ''
        }
      }
    }
  }

  $tmp_dir = '/etc/puppet/tmp'

  # use notifier dir as /etc/csf may not exist yet
  $partial_tcp_in = "${tmp_dir}/csf_partial_tcp_in.conf"
  $partial_udp_in = "${tmp_dir}/csf_partial_udp_in.conf"
  $filepath_csf_allow = "/etc/csf/csf.allow"
}

