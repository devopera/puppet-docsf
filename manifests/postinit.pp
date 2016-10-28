class docsf::postinit (

  # class arguments
  # ---------------
  # setup defaults

  $match = 'TCP_IN = .*',
  $tmp_dir = $docsf::params::tmp_dir,
  $file_replace = $docsf::params::partial_tcp_in,
  $file_target = '/etc/csf/csf.conf',
  $min_size = 10,
  $postamble = '\n\n',

  # end of class arguments
  # ----------------------
  # begin class

) inherits docsf::params {

  # substitue in dynamic port list
  exec { 'docsf_postinit_sub_tcp_in' :
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
    # make awk (<4.1.0) do inplace editing, with a backup file
    command => "cp ${file_target} ${tmp_dir}/docsf_postinit_presub && awk 'BEGIN{getline l < \"${file_replace}\"}/${match}/{gsub(\"${match}\",l)}1' ${file_target} > ${tmp_dir}/docsf_postinit_sub_tcp_in && mv ${tmp_dir}/docsf_postinit_sub_tcp_in ${file_target}",
    # don't substitute port list if for any reason we failed to generate it
    onlyif => "test `wc -c '${file_replace}' | cut -f 1 -d ' '` -ge ${min_size}",
  }->
  # display the status of the TCP_IN for csf.conf
  exec { 'docsf_postinit_sub_readback' :
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => "cat /etc/csf/csf.conf | grep '^TCP_IN = ' | awk ' { print \">>>>>>>>>>> \"\$0\"${postamble}\"; } ' && cat ${file_replace} | awk ' { print \"*********** \"\$0\"${postamble}\"; } '",
    logoutput => true,
  }
}
