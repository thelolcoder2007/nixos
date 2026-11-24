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
      peers = [
        {
          asnum = "4242423729";
          clearnetEndpoint = "nue1.pixiainfra.pixia.eu.org";
          dn42Endpoint-LL = "3729";
          localPort = 51823;
          name = "pixia";
          publickey = "2n/880OXKFlvu1NU7mWUcHiPM9SfYc8prjNIl90Dj2M=";
          remotePort = "23842";
        }
        {
          asnum = "4242420207";
          clearnetEndpoint = "router.ams1.routedbits.com";
          dn42Endpoint-LL = "207";
          localPort = 51821;
          name = "routedbits";
          publickey = "JjAHDWR1CgQd1HJNvURrqUECkN++0bzYxlm57VXjlyc=";
          remotePort = "53842";
        }
        {
          asnum = "4242420230";
          clearnetEndpoint = "sinope.sotecware.net";
          dn42Endpoint-LL = "230";
          localPort = 51824;
          name = "jssfr";
          publickey = "FVvqcKOfUlDzdg+e/K/LFu80n1evXct+F9gnfBzlGTg=";
          remotePort = "53842";
          optionalConfig = ''
            aigp on;
          '';
        }
        {
          asnum = "4242423432";
          clearnetEndpoint = "ams1.dn42.s6v.net";
          dn42Endpoint-LL = "3432";
          localPort = 51822;
          name = "s6v";
          publickey = "YxZCD/u4kn1hkHTkj1yrxKv6gDK+noGDcmkD6v7eg08=";
          remotePort = "42074";
        }
        {
          asnum = "4242421810";
          clearnetEndpoint = "nl42.sabrinaishere.party";
          dn42Endpoint-LL = "1810";
          localPort = 51825;
          name = "sabrina";
          publickey = "bEyqKaQQz9Zg+CCQ36I8SXScFcGopycRm9MaxOpF/gw=";
          remotePort = "23842";
        }
      ];

      DNSconf.dnsZones = [
        "2.3.9.4.1.c.4.5.7.a.d.f.ip6.arpa."
        "224/27.99.23.172.in-addr.arpa."
        "nlgld.dn42."
        "2.4.8.3.4.2.4.0.tel.dn42."
      ];

      DHCPconf = {
        ipv4Config = {
          valid-lifetime = 86400;
          rebind-timer = 43200;
          renew-timer = 7200;
          pool = "172.23.99.225 - 172.23.99.235";
          subnet = "172.23.99.224/27";
          dnsServers = "${(builtins.elemAt config.networking.interfaces.${mainIface}.ipv4.addresses 0).address
          }";
          staticRoutes = "172.20.0.0/14 - 172.23.99.254";
        };
        ipv6Config = {
          RDNSSLifetime = 43200; # 12 hours
          defaultRouteLifetime = 0; # No default route
          prefix = "fda7:54c1:4932::/64";
          RDNSServers = [
            (builtins.elemAt inputs.self.nixosConfigurations.zeus.config.networking.interfaces.ens192.ipv6.addresses 0)
            .address
          ];
          enabled = true;
        };
      };
    in
    [
      (import ../networking/server/BGP/peer.nix {
        inherit
          config
          lib
          pkgs
          peers
          ;
      })
      (import ../networking/server/firewall/DN42.nix {
        inherit config peers;
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
        inherit config lib;
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
      ../networking/server/GPG/hockeypuck.nix
      ../networking/server/telephony/asterisk.nix
      # keep-sorted end
    ];
}
