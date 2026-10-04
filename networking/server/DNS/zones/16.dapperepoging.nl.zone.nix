{ inputs, ... }:
let
  host = ipv4Address: ipv6Address: {
    A = [ (toString ipv4Address) ];
    AAAA = [ (toString ipv6Address) ];
  };
  cname = name: { CNAME = [ name ]; };
  inherit (inputs.nixpkgs) lib;
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

  MX = [
    {
      preference = 0;
      exchange = ".";
    }
  ];

  TXT = [
    "v=spf1; -all"
  ];
  subdomains =
    lib.genAttrs (lib.attrNames inputs.self.nixosConfigurations) (
      name:
      host
        (builtins.elemAt
          inputs.self.nixosConfigurations.${name}.config.networking.interfaces.ens192.ipv4.addresses
          0
        ).address
        (builtins.elemAt
          inputs.self.nixosConfigurations.${name}.config.networking.interfaces.ens192.ipv6.addresses
          0
        ).address
    )
    // {
      _dmarc.TXT = [ "v=DMARC1; p=reject;" ];
      # Other machines
      cerberos = host "10.0.116.1" "2a07:54c1:4932:116::"; # Cerberos is my firewall
      chronos = host "10.0.116.103" "2a07:54c1:4932:116::103"; # Chronos is the PTP clock master, based on Arch linux
      olympos = host "10.0.116.2" "2a07:54c1:4932:116::2"; # Olympos is a hypervisor
      olympos-ipmi = host "10.0.116.22" "2a07:54c1:4932:116::22";

      # CNAMEs
      chat = cname "hermes" // {
        subdomains."*" = cname "hermes";
      };
      # keep-sorted start
      build = cname "xenoi";
      cache = cname "athena";
      dn42 = cname "poseidon";
      matrix = cname "hermes";
      maubot = cname "hermes";
      mc = cname "games";
      monitoring = cname "hera";
      music = cname "apollo";
      ns = cname "zeus";
      tftp = cname "zeus";
      # keep-sorted end
    };
}
