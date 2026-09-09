{ inputs, ... }:
{
  networking.resolvconf.enable = false;
  environment.etc."resolv.conf".text = ''
    		# zeus.16.dapperepoging.nl
    		nameserver ${(builtins.elemAt inputs.self.nixosConfigurations.zeus.config.networking.interfaces.ens192.ipv4.addresses 0).address}
    		nameserver ${(builtins.elemAt inputs.self.nixosConfigurations.zeus.config.networking.interfaces.ens192.ipv6.addresses 0).address}
    		# 1.dns.nothingtohide.nl
    		nameserver 192.42.116.9
    		nameserver 2001:67c:e60:c0c::53:1
    	'';
}
