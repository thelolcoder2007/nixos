{ iface, conf, ... }:

{
  networking = {
    inherit (conf) hostName domain;
    firewall.enable = true;
    nftables.enable = true;
    interfaces.${iface}.useDHCP = true;
  };
}
