{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.x.nginx.virtualHosts;
  clientScript = pkgs.fetchurl {
    url = "https://dn42.g-load.eu/about/certificate-authority/client.sh";
    hash = "sha256-1/QOigfUcc6LUGM9/Ud7CRo9odYSBtfEjDUfOYDxBT0=";
  };
in
{
  options.x.nginx.virtualHosts = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          prodHost = mkEnableOption "Enable this host to run production (aka ask for ACME certs)";
          snakeoilHost = mkEnableOption "Use snakeoil HTTPS certificates for this host";
          DN42Host = mkEnableOption "Use Kioubit's DN42 certificates for this host";
        };
      }
    );
  };
  config = {
    assertions = [
      {
        assertion = lib.all (
          vhost:
          lib.count (x: x) [
            vhost.snakeoilHost
            vhost.prodHost
            vhost.DN42Host
          ] <= 1
        ) (lib.attrValues config.x.nginx.virtualHosts);
        message = "A virtualHost cannot have only have one of the following three attributes set to true: snakeoilHost, prodHost, DN42Host.";
      }
    ];
    sops.secrets."sslprivatekey" = {
      owner = config.users.users.nginx.name;
      group = config.users.groups.nginx.name;
      sopsFile = ./certs/private.key.sops;
      format = "binary";
    };

    security.acme.acceptTerms = lib.any (vhost: vhost.enableACME) (
      lib.attrValues config.services.nginx.virtualHosts
    );
    services.nginx.virtualHosts = lib.genAttrs (lib.attrNames cfg) (
      vhost:
      {
        http2 = true;
        http3 = true;
        http3_hq = true;
      }
      // lib.optionalAttrs (cfg.${vhost}.prodHost) {
        enableACME = true;
        onlySSL = true;
      }
      // lib.optionalAttrs (cfg.${vhost}.snakeoilHost) {
        onlySSL = lib.mkDefault true;
        # TODO: Make SSL certs something else than a public certificate
        sslCertificate = ./certs/certificate.crt;
        sslCertificateKey = config.sops.secrets.sslprivatekey.path;
      }
      // lib.optionalAttrs (cfg.${vhost}.DN42Host) {
        onlySSL = lib.mkDefault true;
        sslCertificate = "/etc/certs/nlgld.dn42/signed.crt";
        sslCertificateKey = "/etc/certs/nlgld.dn42/server.key";
      }
    );
  };

}
// {
  config = lib.mkIf (lib.any (vhost: cfg.${vhost}.DN42Host) (lib.attrNames cfg)) {
    sops.secrets."dn42_secret".path = "/run/dn42-cert/token.txt";

    systemd.services.dn42-cert = {
      description = "Fetch DN42 Certificate using client.sh";

      after = [
        "network-online.target"
        "sops-nix.service"
      ];
      before = [ "nginx.service" ];
      wants = [ "network-online.target" ];

      path = with pkgs; [
        #	keep-sorted start
        bash
        coreutils-full
        curl
        gawk
        gnugrep
        openssl
        # keep-sorted end
      ];

      serviceConfig = {
        Type = "oneshot";
        WorkingDirectory = "/run/dn42-cert";
        DynamicUser = true;
        PrivateTmp = true;
        PrivateDev = true;
      };
      script = ''
        cp ${clientScript} ./client.sh
        chmod +x ./client.sh

        ./client.sh get_certificate nlgld.dn42 '*.nlgld.dn42'

        mkdir -p /etc/certs/nlgld.dn42

        cp signed.crt /etc/certs/nlgld.dn42
        cp server.key /etc/certs/nlgld.dn42

        chmod 0600 /etc/certs/nlgld.dn42/*
        chown nginx:nginx /etc/certs/nlgld.dn42/*
      '';
    };
  };
}
