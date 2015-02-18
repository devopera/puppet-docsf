class docsf::postinit (

  # class arguments
  # ---------------
  # setup defaults

  $match = 'TCP_IN = "',
  $file_replace = '/etc/csf/csf_partial_tcp_in.conf',
  $file_target = '/etc/csf/csf.conf',

  # end of class arguments
  # ----------------------
  # begin class

) inherits docsf::params {

  # substitue in dynamic port list
  exec { 'docsf_postinit_sub_tcp_in' :
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "sed -i -e \$'/^${match}.*\$/{r ${file_replace}\\n d}' ${file_target}",
    # don't substitute port list if for any reason we failed to generate it
    # onlyif => '',
  }

}
