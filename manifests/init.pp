class docsf (

  # class arguments
  # ---------------
  # setup defaults

  $user = 'csf',
  $etcuser = 'root',
  
  # variables used for template substitution
  
  $testing = '0',
  $tcp_in = '80,443,8139,15022',
  # ftp (21) for yum, ssh (22), smtp (25, 2525, 587), web (80, 443), squid proxy (3128), mysql client (3306), puppet (8139,8140), non-std ssh (15022), elasticsearch (9200,9300:9400)
  # temporarily including 522, remove when miata svn deprecated
  $tcp_out = '21,22,25,80,443,587,2525,3128,3306,8139,8140,15022,522,9200,9300:9400',
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
  $csf_ignore = {},
  $csf_pignore = {},
  # concurrent connection limit: Firefox makes up to 15 legit connections, allow 5 max SSH
  $connlimit = '22;5,80;20',
  # sequent connection limit: block a certain number of requests within a certain timeframe
  # - block after 10 SSH connections within 1 minute, for 1 minute
  # - block after 50 HTTP connections in 5 seconds, for 5 seconds
  $portflood = '22;tcp;10;60,80;tcp;50;5',

  # increase process tracking time from 1800 to 3600 by default
  $pt_limit = '3600',
  $pt_userproc = '30',
  $pt_usertime = '3600',
  $pt_usermem = '250',
  
  # run logscanner daily
  $logscanner = 1,
  $logscanner_interval = 'daily',
  $lf_log_syslog = $docsf::params::lf_log_syslog,

  # end of class arguments
  # ----------------------
  # begin class

) inherits docsf::params {

  case $operatingsystem {
    centos, redhat, fedora: {
      package { ['perl', 'perl-libwww-perl', 'perl-Time-HiRes'] :
        ensure => 'present',
      }
    }
    ubuntu, debian: {
      package { ['perl', 'libwww-perl', 'libtime-hires-perl'] :
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

    # clean up
    exec { 'install_csf_cleanup':
      command => 'rm -rf /tmp/csf*',
      path  => '/bin/',
      require => Exec['install_csf'],
      before => File['configure_csf'],
      logoutput => true,
    }

    # create a non-login user for the messenger service
    user { 'create_user_csf':
      name => $user,
      shell => "/sbin/nologin",
      require => Exec['install_csf'],
      before => File['configure_csf'],
      home => '/etc/csf',
    }
  }

  # configure csf using template
  # everytime, not just during install
  file { 'configure_csf':
    path => "/etc/csf/csf.conf",
    content => template('docsf/csf.conf.erb'),
    mode => 0600,
    owner => $etcuser,
    group => $etcuser,
    notify => [Service['start_csf'], Service['start_lfd']],
  }
  file { 'configure_csf_ignore':
    path => "/etc/csf/csf.ignore",
    content => template('docsf/csf.ignore.erb'),
    mode => 0600,
    owner => $etcuser,
    group => $etcuser,
    notify => [Service['start_csf'], Service['start_lfd']],
    require => [File['configure_csf']],
  }
  file { 'configure_csf_pignore':
    path => "/etc/csf/csf.pignore",
    content => template('docsf/csf.pignore.erb'),
    mode => 0600,
    owner => $etcuser,
    group => $etcuser,
    notify => [Service['start_csf'], Service['start_lfd']],
    require => [File['configure_csf']],
  }

  # startup csf and lfd
  service { 'start_csf':
    name => 'csf',
    enable => true,
    ensure => running,
  }
  service { 'start_lfd':
    name => 'lfd',
    enable => true,
    ensure => running,
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
