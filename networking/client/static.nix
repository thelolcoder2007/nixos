{ conf, ... }:

{
  networking = {
    dhcpcd.denyInterfaces = [ conf.iface ];
    firewall.enable = true;
    nftables.enable = true;
    interfaces.${conf.iface} = {
      ipv4 = {
        addresses = [
          {
            address = conf.ipv4Address;
            prefixLength = conf.ipv4PrefixLength or 24;
          }
        ];
        routes = conf.ipv4Routes or [ ];
      };
      ipv6 = {
        addresses = [
          {
            address = conf.ipv6Address;
            prefixLength = conf.ipv6PrefixLength or 64;
          }
        ];
        routes = conf.ipv6Routes or [ ];
      };
    };
  }
  // (builtins.intersectAttrs {
    hostName = null;
    domain = null;
    defaultGateway = null;
    defaultGateway6 = null;
  } conf);
}
