{
  config,
  lib,
  pkgs,
  ...
}:

let
  zabbixUsername = "zabbix";
in
{
  imports = [
    ../database/postgres.nix
  ];
  services = {
    zabbixWeb = {
      enable = true;
      frontend = "nginx";
      hostname = "${config.networking.hostName}.dapperepoging.nl";
      database = {
        socket = "/var/run/postgresql/postgresql.sock";
        type = "pgsql";
        name = "zabbix";
        user = zabbixUsername;
      };
      package = pkgs.zabbix74.web;
      nginx.virtualHost = (import ../webserver/certs/nginx-vhost-snakeoil.nix { inherit pkgs; }) // {
        default = true; # There should be no other NGINX virtualhosts on this host, otherwise monitoring is dependent on other hosts which should not be
        listen = lib.mkForce [
          {
            addr = "0.0.0.0";
            port = 8080;
            ssl = true;
          }
          {
            addr = "[::]";
            port = 8080;
            ssl = true;
          }
        ];
      };
    };
    zabbixServer = {
      enable = true;
      package = pkgs.zabbix74.server-pgsql;
      settings = {
        Timeout = 30;
      };
    };
  };

  services.postgresql = {
    ensureUsers = [
      {
        name = zabbixUsername;
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [
      zabbixUsername
    ];
  };
}
