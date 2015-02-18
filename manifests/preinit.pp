class docsf::preinit (

  # class arguments
  # ---------------
  # setup defaults

  # end of class arguments
  # ----------------------
  # begin class

) inherits docsf::params {

  # setup TCP_IN container so docommon can realise all the virtual fireport resources into it
  concat{ "${::docsf::params::partial_tcp_in}" :
    owner => root,
    group => root,
    mode  => '0644',
  }
  # put at least one fragment into file
  concat::fragment{ "docsf_partial_tcp_in_firstfrag" :
    target  => $docsf::params::partial_tcp_in,
    content => 'TCP_IN = "',
    order => 0,
  }
  concat::fragment{ "docsf_partial_tcp_in_finalfrag" :
    target  => $docsf::params::partial_tcp_in,
    content => '"',
    order => 99,
  }

}
