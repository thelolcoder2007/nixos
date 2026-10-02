let
  host = ipv4Address: ipv6Address: {
    A = [ (toString ipv4Address) ];
    AAAA = [ (toString ipv6Address) ];
  };
  cname = name: { CNAME = [ name ]; };
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
    # VMs managed by Nixos
    apollo = host "10.0.116.10" "2a07:54c1:5932:116::10";
    athena = host "10.0.116.3" "2a07:54c1:5932:116::3";
    hera = host "10.0.116.8" "2a07:54c1:5932:116::8";
    hermes = host "10.0.116.6" "2a07:54c1:5932:116::6";
    poseidon = host "10.0.116.9" "2a07:54c1:5932:116::9";
    xenoi = host "10.0.116.125" "2a07:54c1:5932:116::125";
    zeus = host "10.0.116.5" "2a07:54c1:4932:116::5";

    # Other machines
    cerberos = host "10.0.116.1" "2a07:54c1:4932:116::";
    chronos = host "10.0.116.103" "2a07:54c1:4932:116::103";
    olympos = host "10.0.116.31" "2a07:54c1:4932:116::31";
    olympos-ipmi = host "10.0.116.36" "2a07:54c1:4932:116::36";

    # CNAMEs
    chat = cname "hermes" // {
      subdomains."*" = cname "hermes";
    };
    # keep-sorted start
    build = cname "athena";
    matrix = cname "hermes";
    maubot = cname "hermes";
    monitoring = cname "hera";
    music = cname "apollo";
    ns = cname "zeus";
    tftp = cname "zeus";
    # keep-sorted end
  };
}
