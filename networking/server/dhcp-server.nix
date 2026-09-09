{
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
                name = "domain-name-servers";
                code = 6;
                data = ipv4Config.dnsServers;
              }
              {
                name = "classless-static-route";
                code = 121;
                data = ipv4Config.staticRoutes;
              }
            ];
          }
        ];
      };
    };

    radvd =
      let
        convertRoutes =
          routes:
          map (route: ''
            route ${route} {
            	AdvRoutePreference medium;
             	AdvRouteLifetime ${ipv6Config.routeLifetime}
            };
          '') routes;
        convertRDNSS =
          rdnsservers:
          map (server: ''
            RDNSS ${server} {
            	AdvRDNSSLifetime ${ipv6Config.RDNSSLifetime}
            };
          '') rdnsservers;
      in
      {
        enable = true;
        config = ''
          interface ${interface} {
              AdvSendAdvert on;
              AdvDefaultLifetime ${ipv6Config.defaultRouteLifetime or 0};

              prefix ${ipv6Config.prefix} {
                  AdvOnLink on;
                  AdvAutonomous on;
              };
              ${convertRoutes ipv6Config.routes}
              ${convertRDNSS ipv6Config.RDNSServers}
          };
        '';
      };
  };
}
