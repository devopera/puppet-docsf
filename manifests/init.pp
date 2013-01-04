class docsf {
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
  }
  
  # clean up tmp directory
  exec { 'install_maldet_cleanup':
    path  => '/bin',
    command => 'rm -rf /tmp/maldetect*',
    require => Exec['install_maldet'],
  }
}
