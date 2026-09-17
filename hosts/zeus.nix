{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

let
  mainIface = "ens192";
in
{
  _module.args = {
    inherit mainIface;
  };
  imports =
    let
      staticConf = {
        hostName = "zeus";
        domain = "16.dapperepoging.nl";
        iface = mainIface;
        ipv4Address = "10.0.116.5";
        ipv6Address = "2a07:54c1:4932:116::5";
        defaultGateway = "10.0.116.1";
        defaultGateway6 = "fe80::c1c0";
      };
      DNSconf = {
        dnsZones = [
          "6.1.1.0.2.3.9.4.1.c.4.5.7.0.a.2.ip6.arpa."
          "116.0.10.in-addr.arpa."
          "16.dapperepoging.nl."
        ];
        listenPort = 5353;
      };
      DHCPconf = {
        ipv4Config = {
          validLifetime = 86400;
          rebind-timer = 43200;
          renew-timer = 7200;
          pool = "10.0.116.130 - 10.0.116.150";
          subnet = "10.0.116.0/24";
          dnsServers = "${
            (builtins.elemAt config.networking.interfaces.${mainIface}.ipv4.addresses 0).address
          }, ${(builtins.elemAt config.networking.interfaces.${mainIface}.ipv6.addresses 0).address}";
          staticRoutes = "10.0.111.0 - 10.0.116.1";
          routers = "10.0.116.1";
        };
        ipv6Config = {
          RDNSSLifetime = 43200; # 12 hours
          defaultRouteLifetime = 21600; # 6 hours
          prefix = "2a07:54c1:4932:116::/64";
          RDNSServers = [
            (builtins.elemAt inputs.self.nixosConfigurations.zeus.config.networking.interfaces.ens192.ipv6.addresses 0)
            .address
          ];
        };
      };
    in
    [
      (import ../networking/server/dhcp-server.nix {
        inherit (DHCPconf) ipv4Config ipv6Config;
        inherit config;
        interface = "ens192";
      })
      (import ../networking/client/static.nix { conf = staticConf; })
      (import ../networking/server/DNS/authoritative.nix {
        conf = DNSconf;
        inherit
          config
          inputs
          lib
          pkgs
          mainIface
          ;
      })

      # keep-sorted start
      ../base/base.nix
      ../monitoring/zabbix-agent.nix
      ../networking/client/resolv.conf.nix
      ../networking/client/ssh.nix
      ../networking/client/tailscale.nix
      ../networking/server/DNS/dnsdist.nix
      ../networking/server/tftp.nix
      # keep-sorted end
    ];
}
