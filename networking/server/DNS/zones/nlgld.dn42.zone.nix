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

  subdomains =
    lib.genAttrs (lib.attrNames inputs.self.nixosConfigurations) (
      name:
      let
        ifaceConf =
          if (inputs.self.nixosConfigurations.${name}.config.networking.interfaces ? ens224) then
            inputs.self.nixosConfigurations.${name}.config.networking.interfaces.ens224
          else
            {
              ipv4.addresses = [ {address="";} ];
              ipv6.addresses = [ {address="";} ];
            };
      in
      host ((builtins.elemAt ifaceConf.ipv4.addresses 0).address)
        ((builtins.elemAt ifaceConf.ipv6.addresses 0).address)
    )
    // {
      _dmarc.TXT = [ "v=DMARC1; p=reject;" ];
      olympos = host "172.23.99.250" "fda7:54c1:4932::250";
      chronos = host "172.23.99.251" "fda7:54c1:4932::251";
      ns = cname "poseidon";
      lg = cname "poseidon";
      sip = cname "poseidon";
    };
}
