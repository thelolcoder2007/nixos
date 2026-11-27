{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  host = hostname: {
    PTR = [ "${hostname}.nlgld.dn42." ];
  };
  fwdConfig = import ../nlgld.dn42.zone.nix { inherit inputs; };
in
{
  SOA = {
    nameServer = "ns.nlgld.dn42.";
    adminEmail = "nlgld@dn42";
    serial = 2026112702;
  };
  TTL = 3600;

  NS = [
    "ns.nlgld.dn42."
  ];
  subdomains =
    lib.genAttrs' (builtins.attrNames (lib.filterAttrs (_k: v: v ? A) fwdConfig.subdomains)) (
      subdomain:
      lib.nameValuePair (lib.last (
        lib.splitString "." (builtins.elemAt fwdConfig.subdomains.${subdomain}.A 0)
      )) (host subdomain)
    )
    // {
      "*" = host "dhcp.v4.connected-by";
    }; # All other hosts that I have not described
}
