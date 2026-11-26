{ inputs, ... }:
let
  host = ipv4Address: ipv6Address: {
    A = if ipv4Address != "" then [ (toString ipv4Address) ] else [ ];
    AAAA = if ipv6Address != "" then [ (toString ipv6Address) ] else [ ];
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

  CAA = [
    {
      issuerCritical = false;
      tag = "issue";
      value = "g-load.eu";
    }
    {
      issuerCritical = false;
      tag = "issuewild";
      value = "g-load.eu";
    }
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

  subdomains = # Add A/AAAA records for all NixOS hosts
    lib.genAttrs (builtins.attrNames inputs.self.nixosConfigurations) (
      name:
      let
        ifaceConf =
          if (inputs.self.nixosConfigurations.${name}.config.networking.interfaces ? ens224) then
            inputs.self.nixosConfigurations.${name}.config.networking.interfaces.ens224
          else
            {
              ipv4.addresses = [ { address = ""; } ];
              ipv6.addresses = [ { address = ""; } ];
            };
        getAllAddresses = addresses: map (addresses: addresses.address) addresses;
      in
      {
        A = (getAllAddresses ifaceConf.ipv4.addresses);
        AAAA = (getAllAddresses ifaceConf.ipv4.addresses);
      }
    )
    # Add CNAMEs for all nginx vhosts to their respective physical hosts
    // lib.mergeAttrsList (
      lib.lists.unique (
        lib.flatten (
          map (
            phyhost:
            lib.genAttrs' (builtins.filter (vhost: lib.hasSuffix ".nlgld.dn42" vhost && vhost != phyhost) (
              builtins.attrNames inputs.nixosConfigurations.${phyhost}.config.services.nginx.virtualHosts
            )) (vhost: lib.nameValuePair (lib.removeSuffix ".nlgld.dn42" vhost) (cname phyhost))
          ) (builtins.attrNames inputs.nixosConfigurations)
        )
      )
    )
    # Any other config
    // {
      _dmarc.TXT = [ "v=DMARC1; p=reject;" ];
      olympos = host "172.23.99.250" "fda7:54c1:4932::250";
      chronos = host "172.23.99.251" "fda7:54c1:4932::251";
      ns = host "172.23.99.254" "fda7:54c1:4932::";
      sip = cname "poseidon";
    };
}
