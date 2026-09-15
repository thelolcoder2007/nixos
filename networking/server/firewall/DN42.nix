{
  config,
  peers,
  ...
}:

{
  networking = {
    firewall = {
      logRefusedConnections = true;
      logRefusedUnicastsOnly = false;
      logRefusedPackets = true;
      extraInputRules = builtins.concatStringsSep "\n" (
        map (
          peer:
          ''ip6 saddr fe80::${peer.dn42Endpoint-LL} ip6 daddr fe80::2 iifname "dn42_${peer.asnum}" accept comment "Allow peering from dn42_${peer.asnum}"''
        ) peers
      );
      filterForward = true;
      extraForwardRules = ''
        iifname { ${builtins.concatStringsSep ", " config.networking.firewall.trustedInterfaces} } accept comment "trusted interfaces"
        icmp type echo-request accept comment "allow ping"
        iifname "dn42_*" oifname "dn42_*" accept
      '';
      checkReversePath = false;
    };
    nftables.tables = {
      dn42-natv4 = {
        family = "ip";
        content = ''
            		chain postrouting {
          				type nat hook postrouting priority srcnat - 5; policy accept;
              		oifname "dn42_*" meta mark & 0x00ff0000 == 0x00040000 snat to ${(builtins.elemAt config.networking.interfaces.ens224.ipv4.addresses 0).address}
            		}
        '';
      };
      dn42-natv6 = {
        family = "ip6";
        content = ''
            		chain postrouting {
          				type nat hook postrouting priority srcnat - 5; policy accept;
                 	oifname "dn42_*" meta mark & 0x00ff0000 == 0x00040000 snat to ${(builtins.elemAt config.networking.interfaces.ens224.ipv6.addresses 0).address}
            		}
          		'';
      };
    };
  };

}
