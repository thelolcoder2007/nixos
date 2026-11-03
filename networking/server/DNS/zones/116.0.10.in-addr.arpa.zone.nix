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
    "1" = host "cerberos";
    "2" = host "olympos";
    "4" = host "athena";
    "5" = host "zeus";
    "6" = host "hermes";
    "7" = host "gameserver";
    "8" = host "hera";
    "9" = host "poseidon";
    "10" = host "apollo";
    "22" = host "olympos-ipmi";
    "103" = host "chronos";
    "125" = host "xenoi";
  };
}
