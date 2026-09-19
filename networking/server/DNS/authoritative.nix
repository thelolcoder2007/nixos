{
  config,
  inputs,
  lib,
  pkgs,
  conf,
  mainIface,
  ...
}:
let
  dbPath = "/var/lib/powerdns/dnssec.bind.sqlite3";

  localhost = pkgs.writeText "localhost.zone" (
    inputs.dns.lib.toString "localhost" (import ./zones/localhost.zone.nix)
  );
  localhost-rdnsv4 = pkgs.writeText "127.in-addr.arpa.zone" (
    inputs.dns.lib.toString "127.in-addr.arpa" (import ./zones/127.in-addr.arpa.zone.nix)
  );

  empty = pkgs.writeText "db.empty" (inputs.dns.lib.toString "@" (import ./zones/db.empty.zone.nix));

  localhost-rdnsv6 = pkgs.writeText "1.0..0.ip6.arpa.zone" (
    inputs.dns.lib.toString "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa" (
      import ./zones/1.0..0.ip6.arpa.zone.nix
    )
  );

  compiledDNSzones = lib.genAttrs conf.dnsZones (
    zone:
    pkgs.writeText "${zone}zone" (
      inputs.dns.lib.toString (lib.removeSuffix "." zone) (import ./zones/${zone}zone.nix)
    )
  );
  named-conf-path = pkgs.writeText "named.conf" (
    builtins.concatStringsSep "\n" (
      lib.mapAttrsToList (zone: file: ''
        zone "${zone}" {
          type master;
          file "${file}";
        };
      '') compiledDNSzones
    )
    + ''
      options {
        empty-zones-enable no;
      };

      # Let's be a good internet citizen, shall we?
      zone "localhost" {
          type master;
          file "${localhost}";
          allow-update { none; };
      }; // forward zone for the local host

      zone "127.in-addr.arpa" {
          type master;
          file "${localhost-rdnsv4}";
          allow-update { none; };
      }; // IPv4 loopback network (whole 127/8, per RFC6303)

      zone "0.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // IPv4 "this" network

      zone "255.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // IPv4 broadcast (whole 255/8, per RFC1912)

      zone "254.169.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // IPv4 link-local (169.254.0.0/16)

      zone "2.0.192.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // TEST-NET-1 (192.0.2.0/24)

      zone "100.51.198.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // TEST-NET-2 (198.51.100.0/24)

      zone "113.0.203.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // TEST-NET-3 (203.0.113.0/24)

      zone "10.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (10.0.0.0/8)

      zone "16.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "17.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "18.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "19.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "20.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "21.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "22.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "23.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "24.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "25.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "26.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "27.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "28.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "29.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "30.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "31.172.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (172.16.0.0/12)

      zone "168.192.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC1918 private (192.168.0.0/16)

      zone "64.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "65.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "66.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "67.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "68.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "69.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "70.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "71.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "72.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "73.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "74.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "75.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "76.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "77.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "78.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "79.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "80.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "81.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "82.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "83.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "84.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "85.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "86.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "87.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "88.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "89.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "90.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "91.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "92.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "93.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "94.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "95.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "96.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "97.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "98.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "99.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "100.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "101.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "102.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "103.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "104.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "105.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "106.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "107.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "108.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "109.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "110.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "111.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "112.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "113.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "114.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "115.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "116.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "117.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "118.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "119.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "120.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "121.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "122.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "123.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "124.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "125.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "126.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "127.100.in-addr.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // RFC6598 shared address space (100.64.0.0/10)

      zone "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa" {
          type master;
          file "${localhost-rdnsv6}";
          allow-update { none; };
      }; // IPv6 loopback address (::1)

      zone "0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // IPv6 unspecified address (::)

      zone "d.f.ip6.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // IPv6 locally assigned ULA space (fd00::/8)

      zone "8.e.f.ip6.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // IPv6 link-local (fe80::/10)

      zone "9.e.f.ip6.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // IPv6 link-local (fe80::/10)

      zone "a.e.f.ip6.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // IPv6 link-local (fe80::/10)

      zone "b.e.f.ip6.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // IPv6 link-local (fe80::/10)

      zone "8.b.d.0.1.0.0.2.ip6.arpa" {
          type master;
          file "${empty}";
          allow-update { none; };
      }; // IPv6 documentation prefix (2001:db8::/32)

    ''
  );
in
{
  imports = [
    ../../../base/sops.nix
  ];
  sops.secrets."powerdns-apikey" = { };
  systemd = {
    services = {
      pdns-init-db = {
        description = "Initialize PowerDNS gsqlite3 schema";
        wantedBy = [ "pdns.service" ];
        before = [ "pdns.service" ];
        serviceConfig = {
          Type = "oneshot";
          User = "pdns";
          Group = "pdns";
          RemainAfterExit = true;
        };
        script = ''
          if [ ! -f ${dbPath} ]; then
            echo "Creating PowerDNS SQLite3 database..."
            ${lib.getExe' pkgs.pdns "pdnsutil"} create-bind-db ${dbPath}
            chown pdns:pdns ${dbPath}
          fi
        '';
      };

      pdns-init-dnssec = {
        description = "Initialize DNSSEC for PowerDNS";
        wantedBy = [ "pdns.service" ];
        after = [
          "pdns.service"
          "pdns-init-db.service"
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "pdns";
          Group = "pdns";
          RemainAfterExit = true;
        };
        script = ''
          for domain in $(${lib.getExe' pkgs.pdns "pdnsutil"} list-all-zones master 2>/dev/null); do
            if [ ! $(${lib.getExe' pkgs.pdns "pdnsutil"} zone show $domain 2>/dev/null | grep "Zone has hashed NSEC3 semantics, configuration:" | wc -l) ]; then
              ${lib.getExe' pkgs.pdns "pdnsutil"} secure-zone $domain
              ${lib.getExe' pkgs.pdns "pdnsutil"} set-nsec3 $domain "1 0 0 -"
              ${lib.getExe' pkgs.pdns "pdnsutil"} rectify-zone $domain
            fi
          done
        '';
      };
      pdns.serviceConfig.ReadOnlyPaths = lib.attrValues compiledDNSzones;
    };

    tmpfiles.rules = [
      "d /var/lib/powerdns 0750 pdns pdns -"
    ];
  };

  services.powerdns = {
    enable = true;
    extraConfig = ''
      launch=bind
      bind-config=${named-conf-path}
      bind-dnssec-db=${dbPath}

      # Networking
      local-address=${
        (builtins.elemAt config.networking.interfaces.${mainIface}.ipv4.addresses 0).address
      },127.0.0.1,${
        (builtins.elemAt config.networking.interfaces.${mainIface}.ipv6.addresses 0).address
      },::1
      local-port=${toString (conf.listenPort or 53)}

      distributor-threads=3
      loglevel=9
      log-dns-details=yes

      api=yes
      api-key=$scrypt$ln=10,p=1,r=8$GL7O1Twd82+b3KxSjHPPiA==$9Ti1qEto0CHZoDVyrjfUenecUehSFfx3+lvIio7TjLk=
      webserver=yes
      webserver-address=127.0.0.1
      webserver-port=8081
    '';
  };

  networking.firewall = {
    allowedTCPPorts = [ (conf.listenPort or 53) ];
    allowedUDPPorts = [ (conf.listenPort or 53) ];
  };

  environment.systemPackages = with pkgs; [
    pdns
    sqlite
  ];

  services.zabbixAgent.settings.UserParameter = [
    "pdns.auth.metrics,${lib.getExe pkgs.curl} -s -f -m 5 -H 'X-API-Key: $(${lib.getExe' pkgs.coreutils-full "cat"} ${
      config.sops.secrets."powerdns-apikey".path
    })' http://127.0.0.1:8081/metrics"
  ];
}
