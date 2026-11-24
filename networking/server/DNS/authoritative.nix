{
  config,
  inputs,
  pkgs,
  conf,
  ...
}:
let
  dbPath = "/var/lib/powerdns/dnssec.bind.sqlite3";
  lib = pkgs.lib // inputs.dns.lib;

  localhost = pkgs.writeText "localhost.zone" (
    lib.toString "localhost" (import ./zones/localhost.zone.nix)
  );
  localhost-rdnsv4 = pkgs.writeText "127.in-addr.arpa.zone" (
    lib.toString "127.in-addr.arpa" (import ./zones/127.in-addr.arpa.zone.nix)
  );

  empty = pkgs.writeText "db.empty" (lib.toString "@" (import ./zones/db.empty.zone.nix));

  localhost-rdnsv6 = pkgs.writeText "1.0..0.ip6.arpa.zone" (
    lib.toString "1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.ip6.arpa" (
      import ./zones/1.0..0.ip6.arpa.zone.nix
    )
  );

  compiledDNSzones = lib.genAttrs conf.dnsZones (
    zone:
    pkgs.writeText "${zone}zone" (
      lib.toString (lib.removeSuffix "." zone) (import ./zones/${zone}zone.nix { inherit inputs; })
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
    + builtins.readFile (pkgs.replaceVars ./zones/named.conf.default-zones {
      inherit
        localhost
        localhost-rdnsv4
        localhost-rdnsv6
        empty
        ;
    })
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
      pdns.serviceConfig.ReadOnlyPaths = builtins.attrValues compiledDNSzones;
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
      local-address=0.0.0.0,::
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
    dnstop
  ];

  services.zabbixAgent.settings.UserParameter = [
    "pdns.auth.metrics,${lib.getExe pkgs.curl} -s -f -m 5 -H 'X-API-Key: $(${lib.getExe' pkgs.coreutils-full "cat"} ${
      config.sops.secrets."powerdns-apikey".path
    })' http://127.0.0.1:8081/metrics"
  ];
}
