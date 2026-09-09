{
  lib,
  iface,
  conf,
  ...
}:

{
  networking = {
    inherit (conf) hostName domain;
    useDHCP = lib.mkDefault true;
    firewall.enable = true;
    nftables.enable = true;
    interfaces.${iface}.useDHCP = true;
  };
}
