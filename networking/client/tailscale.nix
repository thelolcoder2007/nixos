{ config, lib, ... }:
let
  advertisedRoutes = lib.concatStringsSep "," (
    [
      "10.0.111.0/24"
      "10.0.116.0/24"
      "2a07:54c1:4932:111::/64"
      "2a07:54c1:4932:116::/64"
    ]
    ++
      lib.optionals (lib.hasInfix "nameserver 172.23.99.253" config.environment.etc."resolv.conf".text) # TODO: Find a better way to see DN42
        [
          "172.20.0.0/14"
          "172.31.0.0/16"
          "fd00::/8"
        ]
  );
in
{
  services.tailscale = {
    enable = true;
    disableTaildrop = true;
    extraSetFlags = [
      "--advertise-exit-node"
      "--accept-dns=false"
      "--advertise-routes"
      advertisedRoutes
    ];
    useRoutingFeatures = "server";
    openFirewall = true;
  };
  networking.firewall.trustedInterfaces = [ config.services.tailscale.interfaceName ];
}
