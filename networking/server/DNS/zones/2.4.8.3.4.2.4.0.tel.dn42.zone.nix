{ ... }:
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
  subdomains."*".NAPTR = [
    {
      order = 100;
      preference = 10;
      flags = "u";
      services = "E2U+sip";
      regexp = "!^(.*)$!sip:\\1@sip.nlgld.dn42:5060!";
    }
  ];
}
