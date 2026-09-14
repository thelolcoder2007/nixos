{
  config,
  interface ? "ens224",
  ipv4Config,
  ipv6Config,
  ...
}:
{
  networking = {
    dhcpcd.denyInterfaces = [
      interface
    ];
  };
  services = {
    kea.dhcp4 = {
      enable = true;
      settings = {
        inherit (ipv4Config) validLifetime rebind-timer renew-timer;
        interfaces-config = {
          interfaces = [
            interface
          ];
        };
        lease-database = {
          name = "/var/lib/kea/dhcp4.leases";
          persist = true;
          type = "memfile";
        };
        subnet4 = [
          {
            id = 1;
            pools = [
              {
                inherit (ipv4Config) pool;
              }
            ];
            inherit (ipv4Config) subnet;
            option-data = [
              {
                name = "routers";
                code = 3;
                data = ipv4Config.routers;
              }
              {
                name = "domain-name-servers";
                code = 6;
                data = ipv4Config.dnsServers;
              }
              {
                code = 15;
                name = "domain-name";
                data = config.networking.domain;
              }
              {
                name = "classless-static-route";
                code = 121;
                data = ipv4Config.staticRoutes;
              }
              # TODO: Make TFTP work
              # {
              #   name = "tftp-server-name";
              #   code = 66;
              #   data = "tftp.16.dapperepoging.nl";
              # }
              # {
              #   name = "bootfile-name";
              #   code = 67;
              #   data = "/netboot.pxe";
              # }
            ];
          }
        ];
      };
    };

    radvd =
      let
        convertRoutes =
          routes:
          if routes == [ ] then
            ""
          else
            builtins.concatStringsSep "\n" (
              map (route: ''
                route ${route} {
                	AdvRoutePreference medium;
                 	AdvRouteLifetime ${toString ipv6Config.routeLifetime}
                };
              '') routes
            );
        convertRDNSS =
          rdnsservers:
          if rdnsservers == [ ] then
            ""
          else
            builtins.concatStringsSep "\n" (
              map (server: ''
                RDNSS ${server} {
                	AdvRDNSSLifetime ${toString ipv6Config.RDNSSLifetime}
                };
              '') rdnsservers
            );
      in
      {
        enable = true;
        config = ''
          interface ${interface} {
              AdvSendAdvert on;
              AdvDefaultLifetime ${toString (ipv6Config.defaultRouteLifetime or 0)};

              prefix ${ipv6Config.prefix} {
                  AdvOnLink on;
                  AdvAutonomous on;
              };
              ${convertRoutes ipv6Config.routes or [ ]}
              ${convertRDNSS ipv6Config.RDNSServers or [ ]}
          };
        '';
      };
  };
}
