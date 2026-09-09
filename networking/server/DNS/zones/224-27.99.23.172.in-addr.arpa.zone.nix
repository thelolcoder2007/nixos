{
  SOA = {
    nameServer = "ns.nlgld.dn42.";
    adminEmail = "nlgld@dn42";
    serial = 2026080402;
  };
  TTL = 3600;

  NS = [
    "ns.nlgld.dn42."
  ];
  subdomains = {
    "254" = {
      PTR = [ "nlgld.dn42." ];
    }; # 172.23.99.254
    "253" = {
      PTR = [ "recursor.nlgld.dn42." ];
    }; # 172.23.99.253
    "*" = {
      PTR = [ "dhcp.v4.connected-by.nlgld.dn42." ];
    }; # All other hosts that I have not described
  };
}
