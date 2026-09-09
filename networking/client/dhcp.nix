{ lib, iface, ... }:

{
  networking = {
    useDHCP = lib.mkDefault true;
    firewall.enable = true;
    nftables.enable = true;
    interfaces.${iface}.useDHCP = true;
  };
}
