{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  host = hostname: {
    PTR = [ "${hostname}.16.dapperepoging.nl." ];
  };
  fwdConfig = import ./16.dapperepoging.nl.zone.nix { inherit inputs; };
in
{
  SOA = {
    nameServer = "zeus.16.dapperepoging.nl.";
    adminEmail = "hostmaster+16@dapperepoging.nl";
    serial = 2026112702;
  };
  TTL = 3600;

  NS = [
    "zeus.16.dapperepoging.nl."
  ];
  subdomains =
    lib.genAttrs' (builtins.attrNames (lib.filterAttrs (_: v: v ? A) fwdConfig.subdomains))
      (
        subdomain:
        lib.nameValuePair (lib.last (
          lib.splitString "." (builtins.elemAt fwdConfig.subdomains.${subdomain}.A 0)
        )) (host subdomain)
      );
}
