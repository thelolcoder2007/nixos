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
      inetConf = {
        hostName = "poseidon";
        domain = "16.dapperepoging.nl";
        iface = mainIface;
        ipv4Address = "10.0.116.9";
        ipv6Address = "2a07:54c1:4932:116::9";
        defaultGateway = "10.0.116.1";
        defaultGateway6 = "fe80::c1c0";
      };

      dn42Conf = {
        # hostName = "poseidon";
        # domain = "nlgld.dn42";
        iface = "ens224";
        ipv4Address = "172.23.99.254";
        ipv4PrefixLength = 27;
        ipv6Address = "fda7:54c1:4932::";
      };

      peer_pixia = {
        asnum = "4242423729";
        clearnetEndpoint = "nue1.pixiainfra.pixia.eu.org";
        remotePort = "23842";
        name = "pixia";
        localPort = 51823;
        publickey = "2n/880OXKFlvu1NU7mWUcHiPM9SfYc8prjNIl90Dj2M=";
        dn42Endpoint-LL = "3729";
      };
      peer_routedbits = {
        asnum = "4242420207";
        clearnetEndpoint = "router.ams1.routedbits.com";
        remotePort = "53842";
        name = "routedbits";
        localPort = 51821;
        publickey = "JjAHDWR1CgQd1HJNvURrqUECkN++0bzYxlm57VXjlyc=";
        dn42Endpoint-LL = "207";
      };
      peer_jssfr = {
        asnum = "4242420230";
        clearnetEndpoint = "sinope.sotecware.net";
        remotePort = "53842";
        name = "jssfr";
        localPort = 51824;
        publickey = "FVvqcKOfUlDzdg+e/K/LFu80n1evXct+F9gnfBzlGTg=";
        dn42Endpoint-LL = "230";
        optionalConfig = ''
          aigp on;
        '';
      };
      DNSconf.dnsZones = [
        "2.3.9.4.1.c.4.5.7.a.d.f.ip6.arpa."
        "224-27.99.23.172.in-addr.arpa."
        "nlgld.dn42."
      ];

      DHCPconf = {
        ipv4Config = {
          validLifetime = 86400;
          rebind-timer = 43200;
          renew-timer = 7200;
          pool = "172.23.99.225 - 172.23.99.235";
          subnet = "172.23.99.224/27";
          dnsServers = "${(builtins.elemAt config.networking.interfaces.${mainIface}.ipv4.addresses 0).address
          }";
          routers = "172.23.99.254";
        };
        ipv6Config = {
          RDNSSLifetime = 43200; # 12 hours
          defaultRouteLifetime = 21600; # 6 hours
          prefix = "fd07:54c1:4932:1::/64";
          RDNSServers = [
            (builtins.elemAt inputs.self.nixosConfigurations.zeus.config.networking.interfaces.ens192.ipv6.addresses 0)
            .address
          ];
        };
      };
    in
    [
      (import ../networking/server/firewall/DN42.nix {
        inherit config;
        peers = [
          peer_pixia
          peer_jssfr
          peer_routedbits
        ];
      })
      (import ../networking/server/BGP/peer.nix {
        inherit config lib pkgs;
        peer = peer_pixia;
      })
      (import ../networking/server/BGP/peer.nix {
        inherit config lib pkgs;
        peer = peer_routedbits;
      })
      (import ../networking/server/BGP/peer.nix {
        inherit config lib pkgs;
        peer = peer_jssfr;
      })
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
      (import ../networking/server/dhcp-server.nix {
        inherit (DHCPconf) ipv4Config ipv6Config;
        inherit config;
        interface = "ens224";
      })
      # keep-sorted start
      (import ../networking/client/static.nix { conf = dn42Conf; })
      (import ../networking/client/static.nix { conf = inetConf; })
      ../base/base.nix
      ../monitoring/zabbix-agent.nix
      ../networking/client/resolv.conf.nix
      ../networking/client/ssh.nix
      ../networking/client/tailscale.nix
      ../networking/server/BGP/BIRD-lg.nix
      ../networking/server/BGP/BIRD.nix
      ../networking/server/BGP/ROA.nix
      # keep-sorted end
    ];
}
