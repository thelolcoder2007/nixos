{ lib, pkgs, ... }:

{
  # Make this Linux box a router plz
  boot.kernel.sysctl = {
    # keep-sorted start
    "net.ipv4.conf.all.forwarding" = 1;
    "net.ipv4.conf.default.rp_filter" = 0;
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.default.rp_filter" = 0;
    "net.ipv6.ip_forward" = 1;
    # keep-sorted end
  };

  services.zabbixAgent.settings.UserParameter =
    let
      v4_param_routes = pkgs.writeShellScript "v4_0207.sh" "${lib.getExe' pkgs.iproute2 "ip"} -4 r | grep \"$1\" | wc -l";
      v6_param_routes = pkgs.writeShellScript "v6_0207.sh" "${lib.getExe' pkgs.iproute2 "ip"} -6 r | grep \"$1\" | wc -l";
      v4_routes = pkgs.writeShellScript "v4_routes.sh" "${lib.getExe' pkgs.iproute2 "ip"} -4 r | wc -l";
      v6_routes = pkgs.writeShellScript "v6_routes.sh" "${lib.getExe' pkgs.iproute2 "ip"} -6 r | wc -l";
    in
    [
      "bgp.v4.routes[*],${v4_param_routes} \"$1\""
      "bgp.v6.routes[*],${v6_param_routes} \"$1\""
      "bgp.v4.num_routes, ${v4_routes}"
      "bgp.v6.num_routes, ${v6_routes}"
    ];

  networking.firewall.allowedTCPPorts = [ 179 ];
  services.bird = {
    enable = true;
    config = ''
      define OWNAS =       4242423842;
      define OWNIP =       172.23.99.254;
      define OWNIPv6 =     fda7:54c1:4932::;
      define OWNNET =      172.23.99.224/27;
      define OWNNETv6 =    fda7:54c1:4932::/48;
      define OWNNETSET =   [172.23.99.224/27+];
      define OWNNETSETv6 = [fda7:54c1:4932::/48+];

      router id OWNIP;

      protocol device {
          scan time 10;
      }


      function is_self_net() -> bool {
        return net ~ OWNNETSET;
      }

      function is_self_net_v6() -> bool {
        return net ~ OWNNETSETv6;
      }

      function is_valid_network() -> bool {
        return net ~ [
          172.20.0.0/14{21,29}, # dn42
          172.20.0.0/24{28,32}, # dn42 Anycast
          172.21.0.0/24{28,32}, # dn42 Anycast
          172.22.0.0/24{28,32}, # dn42 Anycast
          172.23.0.0/24{28,32}, # dn42 Anycast
          172.31.0.0/16+,       # ChaosVPN
          10.100.0.0/14+,       # ChaosVPN
          10.127.0.0/16+,       # neonetwork
          10.0.0.0/8{15,24}     # Freifunk.net
        ];
      }

      roa4 table dn42_roa;
      roa6 table dn42_roa_v6;

      protocol rpki roa_dn42 {
        roa4 { table dn42_roa; };
        roa6 { table dn42_roa_v6; };
        remote 23.82.99.185; # NOTE: Move this to a DN42 address when this is all set up
        port 8082;
        refresh 600;
        retry 300;
        expire 7200;
      }

      function is_valid_network_v6() -> bool {
        return net ~ [
          fd00::/8{44,64} # ULA address space as per RFC 4193
        ];
      }

      protocol kernel {
          scan time 20;
          ipv6 {
              import none;
              export filter {
                  if source = RTS_STATIC then reject;
                  krt_prefsrc = OWNIPv6;
                  accept;
              };
          };
      };

      protocol kernel {
          scan time 20;
          ipv4 {
              import none;
              export filter {
                  if source = RTS_STATIC then reject;
                  krt_prefsrc = OWNIP;
                  accept;
              };
          };
      }

      protocol static {
          route OWNNET reject {
              igp_metric = 53;
          };
          ipv4 {
              import all;
              export none;
          };
      }

      protocol static {
          route OWNNETv6 reject {
              igp_metric = 53;
          };
          ipv6 {
              import all;
              export none;
          };
      }

      protocol bfd {};

      template bgp dnpeers {
          local as OWNAS;
          path metric on;

          ipv4 {
              import filter {
                if is_valid_network() && !is_self_net() then {
                  if (roa_check(dn42_roa, net, bgp_path.last) != ROA_VALID) then {
                    # Reject when unknown or invalid according to ROA
                    print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                    reject;
                  } else accept;
                } else reject;
              };
              export filter { if is_valid_network() && source ~ [RTS_STATIC, RTS_BGP] then accept; else reject; };
              import limit 9000 action block;
              import table;
          };

          ipv6 {
              import filter {
                if is_valid_network_v6() && !is_self_net_v6() then {
                  if (roa_check(dn42_roa_v6, net, bgp_path.last) != ROA_VALID) then {
                    # Reject when unknown or invalid according to ROA
                    print "[dn42] ROA check failed for ", net, " ASN ", bgp_path.last;
                    reject;
                  } else accept;
                } else reject;
              };
              export filter { if is_valid_network_v6() && source ~ [RTS_STATIC, RTS_BGP] then accept; else reject; };
              import limit 9000 action block;
              import table;
          };
      }
    '';
  };
}
