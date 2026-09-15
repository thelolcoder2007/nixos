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
    "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = {
      PTR = [ "nlgld.dn42." ];
    }; # fda7:54c1:4932::
    "*.1.0.0.0" = {
      PTR = [ "dhcp.v6.connected-by.nlgld.dn42." ];
    }; # fda7:54c1:4932:1::/64
    "*" = {
      PTR = [ "v6.connected-by.nlgld.dn42." ];
    }; # fda7:54c1:4932:: - fda7:54c1:4932:ffff:ffff:ffff:ffff:ffff
  };
}
