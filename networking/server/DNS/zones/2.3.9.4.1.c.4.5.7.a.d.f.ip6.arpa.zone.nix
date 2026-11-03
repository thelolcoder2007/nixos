{ ... }:
let
  host = hostname: {
    PTR = [ "${hostname}.nlgld.dn42." ];
  };
in
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
    "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "poseidon";
    "0.5.2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "olympos";
    "1.5.2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "chronos";
    "3.5.2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "zeus";
    "*" = host "v6.connected-by"; # fda7:54c1:4932::/48
  };
}
