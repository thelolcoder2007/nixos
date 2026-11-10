{ config, lib, ... }:

{
  imports = [
    ../base/sops.nix
    ../database/postgres.nix
  ];
  sops.secrets = lib.genAttrs [ "grafana_secret_key" "grafana_admin_password" ] (_: {
    owner = config.users.users.grafana.name;
    restartUnits = [ "grafana.service" ];
  });
  security.acme = {
    acceptTerms = true;
    defaults.email = "thomas.erents@gmail.com";
    certs."grafana.16.dapperepoging.nl" = {
      group = "grafana";
      reloadServices = [ "grafana.service" ];
      server = "https://certs.16.dapperepoging.nl/acme/acme/directory";
      listenHTTP = ":80";
    };
  };
  services.postgresql = {
    ensureUsers = [
      {
        name = "grafana";
        ensureDBOwnership = true;
      }
    ];
    ensureDatabases = [
      "grafana"
    ];
  };
  services.grafana = {
    enable = true;
    openFirewall = true;
    settings = {
      database = {
        host = "/var/run/postgresql";
        type = "postgres";
        user = "grafana";
      };
      security.secret_key = "$__file{${config.sops.secrets."grafana_secret_key".path}}";
      server = {
        domain = "grafana.16.dapperepoging.nl";
        http_addr = "[::]";
        protocol = "h2";
        enable_gzip = true;
        cert_file = "/var/lib/acme/grafana.16.dapperepoging.nl/fullchain.pem";
        cert_key = "/var/lib/acme/grafana.16.dapperepoging.nl/key.pem";
      };
    };

  };
}
