{ config, peers, ... }:

{
  imports = [
    ./default.nix
  ];
  networking = {
    firewall = {
      trustedInterfaces = [
        "ens192"
        "ens224"
      ];
      extraInputRules = builtins.concatStringsSep "\n" (
        map (peer: ''
          ip6 saddr fe80::${peer.dn42Endpoint-LL} ip6 daddr fe80::2 iifname "dn42_${peer.asnum}" accept comment "Allow peering from dn42_${peer.asnum}";
        '') peers
      );
      filterForward = true;
      extraForwardRules = ''
        iifname tailscale0 accept comment "Allow tailscale";
        iifname ens192 drop comment "Do not route ens192 traffic, that is not our business";
        oifname ens192 drop comment "Do not route ens192 traffic, that is not our business";
        iifname ens224 accept;
        icmp type echo-request accept comment "allow ping";
        iifname "dn42_*" oifname "dn42_*" accept;
      '';
      checkReversePath = false;
    };
    nftables.tables = {
      dn42-natv4 = {
        family = "ip";
        content = ''
          chain postrouting {
           	type nat hook postrouting priority srcnat - 5; policy accept;
           	oifname "dn42_*" meta mark & 0x00ff0000 == 0x00040000 counter snat to ${(builtins.elemAt config.networking.interfaces.ens224.ipv4.addresses 0).address}
          }
        '';
      };
      dn42-natv6 = {
        family = "ip6";
        content = ''
          chain postrouting {
          	type nat hook postrouting priority srcnat - 5; policy accept;
           	oifname "dn42_*" meta mark & 0x00ff0000 == 0x00040000 counter snat to ${(builtins.elemAt config.networking.interfaces.ens224.ipv6.addresses 0).address}
          }
        '';
      };
    };
  };

}
