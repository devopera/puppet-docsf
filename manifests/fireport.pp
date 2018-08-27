
# alias the firewall port opening
define docsf::fireport (
  # fields from example42 firewall module's 'firewall' resource type
  $protocol = $proto,
  
  # fields shared [syntax match] between puppetlabs and example42, but different defaults
  $action = undef,
  $source = undef,
  $destination = undef,
  $port = $dport,
  
  # fields from puppetlabs firewall module's 'firewall' resource type
  $dport = undef,
  $proto = 'tcp',
  
) {

  include docsf::params

  if ($source == undef) {
    if ($protocol =~ /tcp/) {
      if defined(Concat["${::docsf::params::partial_tcp_in}"]) {
        # add fragment to target file
        concat::fragment{ "docsf_fireport_dpt_tcp_${port}" :
          target  => $docsf::params::partial_tcp_in,
          content => "${port},",
          # use port number for ordering, so ports appear in numerical order
          order => $port,
        }
      }
    }
    if ($protocol =~ /udp/) {
      if defined(Concat["${::docsf::params::partial_udp_in}"]) {
        # add fragment to target file
        concat::fragment{ "docsf_fireport_dpt_udp_${port}" :
          target  => $docsf::params::partial_udp_in,
          content => "${port},",
          # use port number for ordering, so ports appear in numerical order
          order => $port,
        }
      }
    }
  } else {
    if defined(Concat["${::docsf::params::filepath_csf_allow}"]) {
      # if source is defined use csf.allow with named IP and port
      concat::fragment{ "docsf_fireport_srcip_${source}_dpt_${port}" :
        target  => $docsf::params::filepath_csf_allow,
        content => "${proto}|in|d=${port}|s=${source}\n",
        order => 100,
      }
    }
  }

}

