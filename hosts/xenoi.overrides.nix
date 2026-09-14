{ lib, ... }:

let
  ip_addr4 = "10.0.116.1";
  ip_addr6_ll = "fe80::c1c0"; # fe80::cisco
in
{
  networking = {
    hostName = lib.mkForce "xenoi";
    interfaces.ens192 = lib.mkForce {
      ipv6.addresses = [
        {
          address = "2a07:54c1:4932:116::125";
          prefixLength = 64;
        }
      ];
      ipv4 = {
        addresses = [
          {
            address = "10.0.116.125";
            prefixLength = 24;
          }
        ];
        routes = [
          {
            address = "10.0.111.0";
            prefixLength = 24;
            via = ip_addr4;
          }
        ];
      };
    };
    defaultGateway.address = lib.mkForce ip_addr4;
    defaultGateway6.address = lib.mkForce ip_addr6_ll;
  };
  boot.initrd.systemd.emergencyAccess = true; # Because I fuck up sometimes
  imports = [
    ../convert/vert-sh.nix
    ../convert/vertd.nix
  ];
}
