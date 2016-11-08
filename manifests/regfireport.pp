
# open a fireport and register in motd
define docsf::regfireport (
  $port,
  $port_known_as = 'UNK',
  $source = undef,
  $protocol = 'tcp',
  $firewall_module = 'docsf',
) {
  @docommon::fireport { "docsf-regfireport-${protocol}-${port}-${title}-${source}":
    port => $port,
    source => $source,
    protocol => $protocol,
    firewall_module => $firewall_module,
  }
  @domotd::register { "${port_known_as}(${port}|${title})" : }
}

