{ pkgs, ... }:
{
  imports = [
    ../../../database/postgres.nix
    ../HTTP/defaults.nix
  ];
  services.postgresql = {
    ensureDatabases = [ "hockeypuck" ];
    ensureUsers = [
      {
        name = "hockeypuck";
        ensureDBOwnership = true;
      }
    ];
  };
  services.hockeypuck = {
    enable = true;
    settings = {
      hockeypuck = {
        contact = "68416CBB1288E1294CCDA0BFB0A754DC477B9268";
        hostname = "keys.nlgld.dn42";
        adminKeys = [ "E374815FC754462B1C343562FDC399DE8F7E200B" ];
        loglevel = "INFO";
        logfile = "/var/log/hockeypuck/hockeypuck.log";
        indexTemplate = "${pkgs.hockeypuck-web}/share/templates/index.html.tmpl";
        vindexTemplate = "${pkgs.hockeypuck-web}/share/templates/index.html.tmpl";
        statsTemplate = "${pkgs.hockeypuck-web}/share/templates/stats.html.tmpl";
        webroot = "${pkgs.hockeypuck-web}/share/webroot";

        hkp = {
          bind = ":11371";
          advertisedBind = "keys.nlgld.dn42:11371";
        };

        openpgp.db = {
          driver = "postgres-jsonb";
          dsn = "database=hockeypuck host=/var/run/postgresql sslmode=disable";
        };
        metrics = {
          metricsAddr = "[::1]:9102";
          metricsPath = "/metrics";
        };
      };
    };
  };
  services.zabbixAgent.settings.UserParameter = [
    "gpgserver.metrics,'curl [::1]:9102/metrics'"
  ];
  x.nginx.virtualHosts."keys.nlgld.dn42".DN42Host = true;
  services.nginx.virtualHosts."keys.nlgld.dn42".locations."/".proxyPass = "http://[::1]:11371";
}
