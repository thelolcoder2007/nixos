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
    nameServer = "zeus.16.dapperepoging.nl.";
    adminEmail = "hostmaster+16@dapperepoging.nl";
    serial = 2026090902;
  };
  TTL = 3600;

  NS = [
    "zeus.16.dapperepoging.nl."
  ];

  CAA = [
    {
      issuerCritical = false;
      tag = "issue";
      value = "dapperepoging.nl";
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
  subdomains =
    # Add A/AAAA records for all NixOS hosts
    lib.genAttrs (builtins.attrNames inputs.self.nixosConfigurations) (
      name:
      let
        ifaceConf =
          if (inputs.self.nixosConfigurations.${name}.config.networking.interfaces ? ens192) then
            inputs.self.nixosConfigurations.${name}.config.networking.interfaces.ens192
          else
            {
              ipv4.addresses = [ { address = ""; } ];
              ipv6.addresses = [ { address = ""; } ];
            };
        getAllAddresses = addresses: map (addresses: addresses.address) addresses;
      in
      lib.optionalAttrs
        (
          (getAllAddresses ifaceConf.ipv4.addresses != "") && (getAllAddresses ifaceConf.ipv6.addresses != "")
        )
        {
          A = (getAllAddresses ifaceConf.ipv4.addresses);
          AAAA = (getAllAddresses ifaceConf.ipv6.addresses);
        }
    )
    # Add CNAMEs for all nginx vhosts to their respective physical hosts
    // lib.mergeAttrsList (
      lib.lists.unique (
        lib.flatten (
          map (
            phyhost:
            lib.genAttrs' (builtins.filter
              (vhost: lib.hasSuffix ".16.dapperepoging.nl" vhost && vhost != "${phyhost}.16.dapperepoging.nl")
              (builtins.attrNames inputs.self.nixosConfigurations.${phyhost}.config.services.nginx.virtualHosts)
            ) (vhost: lib.nameValuePair (lib.removeSuffix ".16.dapperepoging.nl" vhost) (cname phyhost))
          ) (builtins.attrNames inputs.self.nixosConfigurations)
        )
      )
    )
    # Any other config
    // {
      _dmarc.TXT = [ "v=DMARC1; p=reject;" ];

      _gateway = cname "cerberos";
      # Other machines
      cerberos = host "10.0.116.1" "2a07:54c1:4932:116::"; # Cerberos is my router
      chronos = host "10.0.116.103" "2a07:54c1:4932:116::103"; # Chronos is the PTP clock master, based on Arch linux
      olympos = host "10.0.116.2" "2a07:54c1:4932:116::2"; # Olympos is a hypervisor
      olympos-ipmi = host "10.0.116.22" "2a07:54c1:4932:116::22";

      # CNAMEs
      # keep-sorted start
      mc = cname "pankration";
      ns = host "10.0.116.5" "2a07:54c1:4932:116::5";
      tftp = cname "zeus";
      # keep-sorted end
    };
}
