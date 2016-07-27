Facter.add("configserver_firewall") do
  has_weight 100
  setcode do
    if (File.exist? "/usr/lib/systemd/system/csf.service") || (File.exist? "/etc/init.d/csf")
      "true"
    else
      "false"
    end
  end
end
