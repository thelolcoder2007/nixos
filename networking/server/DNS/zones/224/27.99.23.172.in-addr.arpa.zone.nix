{ ... }:
let
	host = hostname: { PTR = ["${hostname}.nlgld.dn42."];};
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
    "250" = host "olympos";
    "251" = host "chronos";
    "253" = host "zeus";
    "254" = host "poseidon";
    "*" = host "dhcp.v4.connected-by"; # All other hosts that I have not described
  };
}
