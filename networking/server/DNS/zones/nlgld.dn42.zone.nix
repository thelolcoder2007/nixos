{ dns }:
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

  A = [ "172.23.99.254" ];

  AAAA = [
    "fda7:54c1:4932::"
  ];

  MX = [
    {
      preference = 0;
      exchange = ".";
    }
  ];

  TXT = [
    "v=spf1; -all"
  ];

  subdomains = with dns.lib.combinators; rec {
    ns = host "172.23.99.254" "fda7:54c1:4932::";
    _dmarc.TXT = [ "v=DMARC1; p=reject;" ];

    recursor = host "172.23.99.253" "fda7:54c1:4932::253";

    lg = ns;
    home.CNAME = [ "lg" ];
  };
}
