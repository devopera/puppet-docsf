[devopera](http://devopera.com)-[docsf](http://devopera.com/module/docsf)
==============

[ConfigServer Firewall](http://configserver.com/cp/csf.html) (csf) and Login Failure Daemon (lfd) are designed to protect online servers by providing an adaptive firewall and access/process monitoring service.  CSF in turn uses IPtables to actually implement the firewall rules.  This module also includes Linux Malware Detect (maldet) for detecting malware.

Original Gist came from https://gist.github.com/2772865 and https://github.com/apocas/puppet-cpanel

Changlog
--------

2014-02-20

  * Fixed minor order issue on configuration files csf_ignore and csf_pignore.conf

2014-02-12

  * Making available as a module on Puppet Forge

2014-01-27

  * Added vars to allow additions to csf.ignore and csf.pignore

2013-05-09

  * Added 21 to default outgoing ports for yum updates

2013-04-11

  * Added basic maldet configuration

Usage
-----

Setup CSF firewall with defaults

    class { 'docsf': }

Setup CSF firewall to allow in certain ports, alert to specific email and ignore scripted executables

    class { 'docsf':
      # allow web, ssh (on 15022), puppet, nrpe (on 5666)
      tcp_in => "80,15022,8139,8140,5666",
      lf_alert_to => 'me@example.com',
      csf_pignore => ['exe:/usr/bin/rsync', 'exe:/usr/bin/svn', 'exe:/usr/sbin/nrpe'],
    }

Operating System support
------------------------

Tested with CentOS 6

Copyright and License
---------------------

Copyright (C) 2012 Lightenna Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
