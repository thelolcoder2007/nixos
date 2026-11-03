{ ... }:
let
  host = hostname: {
    PTR = [ "${hostname}.16.dapperepoging.nl." ];
  };
in
{
  SOA = {
    nameServer = "zeus.16.dapperepoging.nl.";
    adminEmail = "hostmaster+16@dapperepoging.nl";
    serial = 2026090902;
  };
  TTL = 3600;

  NS = [
    "zeus.16.dapperepoging.nl."
  ];
  subdomains = {
    "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "cerberos";
    "2.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "olympos";
    "4.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "athena";
    "5.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "zeus";
    "6.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "hermes";
    "7.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "gameserver";
    "8.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "hera";
    "9.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "poseidon";
    "0.1.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "apollo";
    "2.2.0.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "olympos-ipmi";
    "3.0.1.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "chronos";
    "5.2.1.0.0.0.0.0.0.0.0.0.0.0.0.0" = host "xenoi";
  };
}
