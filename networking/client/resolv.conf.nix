{ config, inputs, ... }:
{
  networking.resolvconf.enable = false;
  environment.etc."resolv.conf".text = ''
    # zeus.16.dapperepoging.nl
    nameserver ${(builtins.elemAt inputs.self.nixosConfigurations.zeus.config.networking.interfaces.ens192.ipv4.addresses 0).address}
    nameserver ${(builtins.elemAt inputs.self.nixosConfigurations.zeus.config.networking.interfaces.ens192.ipv6.addresses 0).address}
    # DC02
    nameserver 10.0.111.2
    search ${config.networking.domain}
    options edns0
  '';
}
