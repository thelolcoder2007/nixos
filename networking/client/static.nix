{
  lib,
  iface,
  conf,
  ...
}:

{
  networking = {
    useDHCP = lib.mkDefault true;
    firewall.enable = true;
    nftables.enable = true;
    interfaces.${iface} = {
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
