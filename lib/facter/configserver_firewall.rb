Facter.add("configserver_firewall") do
  has_weight 100
  setcode do
    if File.exist? "/etc/init.d/csf"
      "true"
    else
      "false"
    end
  end
end
