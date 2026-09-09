{ conf, ... }:

{
  networking = {
    inherit (conf) hostName domain;
    dhcpcd.denyInterfaces = [ conf.iface ];
    firewall.enable = true;
    nftables.enable = true;
    interfaces.${conf.iface} = {
      ipv4 = {
        addresses = [ conf.ipv4Address ];
        routes = conf.ipv4Routes or [ ];
      };
      ipv6 = {
        addresses = [ conf.ipv6Address ];
        routes = conf.ipv6Routes or [ ];
      };
    };
  };
}
