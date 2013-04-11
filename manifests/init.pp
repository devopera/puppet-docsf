class docsf (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'csf',
  $etcuser = 'root',
  
  # variables used for template substitution
  
  $testing = '0',
  $tcp_in = '80,443,8139,15022',
  # temporarily including 15422, remove when testbed deprecated
  $tcp_out = '22,25,80,443,8140,8139,15022,15422',
  $udp_in = '',
  $udp_out = '123',
  $syslog_check = '3600',
  $lf_alert_to = 'admin@example.com',
  $lf_alert_from = "lfd.csf.daemon@${::fqdn}",
  $lf_dshield = '86400',
  $lf_spamhaus = '86400',
  $messenger = '1',
  $messenger_user = 'csf',
  $messenger_html_in = '80',
  $messenger_text_in = '',
  $logscanner = 1,
  $logscanner_interval = 'daily',

  # end of class arguments
  # ----------------------
  # begin class

) {

  case $operatingsystem {
    centos, redhat: {
      package { 'perl':
        name => ['perl', 'perl-libwww-perl', 'perl-Time-HiRes'],
        ensure => 'present',
      }
    }
    ubuntu, debian: {
      package { 'perl':
        name => ['perl', 'libwww-perl', 'libtime-hires-perl'],
        ensure => 'present',
      }
    }
  }

  exec { 'enter-class-csf':
    command => "echo ConfigServer initially installed? ${configserver_firewall}",
    path  => '/bin',
    logoutput => true,
  }
  
  # install configserver firewall
  if $configserver_firewall == 'false' {
    exec { 'download_csf':
      command => 'wget http://www.configserver.com/free/csf.tgz -O /tmp/csf.tgz',
      path  => '/usr/bin',
      creates => '/tmp/csf.tgz',
      logoutput => true,
    }

    exec { 'unzip_csf':
      command => 'tar -zxvf /tmp/csf.tgz --directory=/tmp',
      path  => '/bin/',
      creates => '/tmp/csf/',
      require => Exec['download_csf'],
      logoutput => true,
    }

    exec { 'install_csf':
      command => 'sh /tmp/csf/install.sh',
      cwd   => '/tmp/csf/',
      path  => '/bin/',
      require => [Exec['unzip_csf'], Package['perl']],
      creates => '/etc/init.d/csf',
      logoutput => false,
    }

    # create a non-login user for the messenger service
    user { 'create_user_csf':
      name => $user,
      shell => "/sbin/nologin",
      require => Exec['install_csf'],
      home => '/etc/csf',
    }

    # configure csf using template
    file { 'configure_csf':
      path => "/etc/csf/csf.conf",
      content => template('docsf/csf.conf.erb'),
      mode => 0600,
      owner => $etcuser,
      group => $etcuser,
      require => [User['create_user_csf'], Exec['install_csf']],
    }
    file { 'configure_csf_pignore':
      path => "/etc/csf/csf.pignore",
      content => template('docsf/csf.pignore.erb'),
      mode => 0600,
      owner => $etcuser,
      group => $etcuser,
      require => [User['create_user_csf'], Exec['install_csf']],
    }


    # startup csf and lfd
    service { 'start_csf':
      name => 'csf',
      enable => true,
      ensure => running,
      require => File['configure_csf'],
    }
    service { 'start_lfd':
      name => 'lfd',
      enable => true,
      ensure => running,
      require => File['configure_csf'],
    }

    # clean up
    exec { 'install_csf_cleanup':
      command => 'rm -rf /tmp/csf*',
      path  => '/bin/',
      require => Exec['install_csf'],
      logoutput => true,
    }
  }
  
  # install malware detection
  exec { 'install_maldet':
    cwd => "/tmp",
    command => "/usr/bin/wget -N http://www.rfxn.com/downloads/maldetect-current.tar.gz && tar -xzf maldetect-current.tar.gz && cd maldetect* && /bin/bash install.sh",
    creates => "/usr/local/maldetect"
  }->
  file { 'configure_maldet':
    path => '/usr/local/maldetect/conf.maldet',
    content => template('docsf/conf.maldet.erb'),
    mode => 0600,
    owner => $etcuser,
    group => $etcuser,
  }
  
  # clean up tmp directory
  exec { 'install_maldet_cleanup':
    path  => '/bin',
    command => 'rm -rf /tmp/maldetect*',
    require => Exec['install_maldet'],
  }
}
