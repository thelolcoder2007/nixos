{
  networking.firewall = {
    logRefusedConnections = true;
    logRefusedUnicastsOnly = false;
    logRefusedPackets = true;
    extraInputRules = ''
      ip saddr { 10.0.111.8, 10.0.116.8 } tcp dport 10050 accept comment "monitoring from monitoring servers";
      ip6 saddr { 2a07:54c1:4932:111::8, 2a07:54c1:4932:116::8 } tcp dport 10050 accept comment "monitoring from monitoring servers";
    '';
  };
}
