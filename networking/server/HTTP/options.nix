{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.x.nginx.virtualHosts;
  clientScript = pkgs.writeShellScript "client.sh" ''

  # Kioubit Certificate Authority client script
  # Adapted for NixOS by Erents
  # Version 1.1.2-NIXOS

  set -eu

  ENDPOINT="https://dn42.g-load.eu/utilityAPI/ca/v1/request"
  TOKEN_FILE="''${TOKEN_FILE:-token.txt}"

  performRequest() {
    csr_data="$1"

    if [ -z "$csr_data" ]; then
        echo "Error: CSR data is empty."
        exit 1
    fi

    if [ ! -f "$TOKEN_FILE" ]; then
      echo "Error: Token file '$TOKEN_FILE' is missing. It must be generated once on the webpage and then saved as a file called '$TOKEN_FILE'"
      exit 2
    fi

    api_token=$(${lib.getExe' pkgs.coreutils "cat"} "$TOKEN_FILE")

    exit_code=0
    result=$(${lib.getExe pkgs.curl} --fail-with-body --silent "$ENDPOINT" -F "csr=$csr_data" -F "token=$api_token") || exit_code=$?
    if [ $exit_code -ne 0 ]; then
      echo "Error: Remote error message:"
      echo "$result"
      exit 1
    fi

    echo "$result" > signed.crt
    echo "Saved signed certificate to 'signed.crt'"
    echo "Success"
    echo "--- The following files need to be configured in your webserver ---"
    echo "Private key: server.key"
    echo "Signed certificate: signed.crt"
  }

  get_certificate() {
    domain="$1"
    echo "CSR request for: ''${domain}, *.''${domain}. If you need to customize this, create a custom CSR and then use the 'sign_csr' command"
    echo "Generating private key and CSR..."
    csr_content=$(${lib.getExe pkgs.openssl} req -nodes -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -keyout server.key -out - -subj "/CN=''${domain}" -addext "subjectAltName = DNS:''${domain}, DNS:*.''${domain}" 2>/dev/null)
    performRequest "$csr_content"
  }

  # MAIN
  if [ -z "''${2-}" ]; then
    echo "Error: Domain argument missing"
    exit 2
  fi
  get_certificate "$2"
  exit 0
  '';
in
{
  options.x.nginx.virtualHosts = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          prodHost = mkEnableOption "Use Actalis certs for this host";
          snakeoilHost = mkEnableOption "Use self-signed certificates for this host (WARN: Only one certificate is shared between all vhosts with this option)";
          DN42Host = mkEnableOption "Use Kioubit's DN42 certificates for this host";
          localAcmeHost = mkEnableOption "Use Dapperepoging Internal CA certificates for this host";
        };
      }
    );
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = lib.all (
            vhost:
            lib.count (x: x) [
              vhost.snakeoilHost
              vhost.prodHost
              vhost.DN42Host
              vhost.localAcmeHost
            ] <= 1
          ) (lib.attrValues cfg);
          message = "A virtualHost cannot have only have at most one of the following four attributes set to true: snakeoilHost, prodHost, DN42Host, localAcmeHost";
        }
      ];

      sops.secrets = {
        "sslprivatekey" = lib.mkIf (lib.any (vhost: vhost.snakeoilHost) (lib.attrValues cfg)) {
          owner = config.users.users.nginx.name;
          group = config.users.groups.nginx.name;
          sopsFile = ./certs/private.key.sops;
          format = "binary";
        };
        "acme_env" = lib.mkIf (lib.any (vhost: vhost.prodHost) (lib.attrValues cfg)) {
          owner = config.users.users.nginx.name;
          group = config.users.groups.nginx.name;
          sopsFile = ./certs/env-acme.sops;
          format = "binary";
        };
      };

      security.acme = {
        acceptTerms = lib.any (vhost: vhost.prodHost || vhost.localAcmeHost) (lib.attrValues cfg);
        defaults = lib.mkIf (lib.any (vhost: vhost.prodHost) (lib.attrValues cfg)) {
          acceptTerms = true;
          defaults = {
            email = "thomas.erents@gmail.com";
            server = "https://acme-api.actalis.com/acme/directory";
            environmentFile = config.sops.secrets."acme_env".path;
          };
        };
        certs = lib.genAttrs (lib.attrNames (lib.filterAttrs (_: v: v.localAcmeHost) cfg)) (_: {
          server = "https://certs.16.dapperepoging.nl/acme/acme/directory";
        });
      };
      services.nginx.virtualHosts = lib.genAttrs (lib.attrNames cfg) (
        vhost:
        {
          http2 = true;
          http3 = true;
          http3_hq = true;
        }
        // lib.optionalAttrs (cfg.${vhost}.prodHost) {
          # enableACME = true;
          # forceSSL = true;
        }
        // lib.optionalAttrs (cfg.${vhost}.localAcmeHost) {
          enableACME = lib.mkForce true;
          forceSSL = lib.mkDefault true;
        }
        // lib.optionalAttrs (cfg.${vhost}.snakeoilHost) {
          forceSSL = lib.mkDefault true;
          sslCertificate = ./certs/certificate.crt;
          sslCertificateKey = config.sops.secrets.sslprivatekey.path;
        }
        // lib.optionalAttrs (cfg.${vhost}.DN42Host) {
          forceSSL = lib.mkDefault true;
          sslCertificate = "/etc/certs/nlgld.dn42/signed.crt";
          sslCertificateKey = "/etc/certs/nlgld.dn42/server.key";
        }
      );
    }

    (lib.mkIf (lib.any (vhost: vhost.DN42Host) (lib.attrValues cfg)) {
      sops.secrets."dn42_secret".path = "/run/dn42-cert/token.txt";
      systemd = {
        timers.dn42-cert = {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "Weekly";
            Unit = "dn42-cert.service";
          };
        };
        services.dn42-cert = {
          description = "Fetch DN42 Certificate using client.sh";
          after = [
            "network-online.target"
            "sops-nix.service"
          ];
          before = [ "nginx.service" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            Type = "oneshot";
            WorkingDirectory = "/run/dn42-cert";
            PrivateTmp = true;
          };
          script = ''
            ${lib.getExe' pkgs.coreutils "cp"} ${clientScript} ./client.sh
            ${lib.getExe' pkgs.coreutils "chmod"} +x ./client.sh
            ./client.sh get_certificate nlgld.dn42
            ${lib.getExe' pkgs.coreutils "mkdir"} -p /etc/certs/nlgld.dn42
            ${lib.getExe' pkgs.coreutils "cp"} signed.crt /etc/certs/nlgld.dn42
            ${lib.getExe' pkgs.coreutils "cp"} server.key /etc/certs/nlgld.dn42
            ${lib.getExe' pkgs.coreutils "chmod"} 0600 /etc/certs/nlgld.dn42/*
            ${lib.getExe' pkgs.coreutils "chown"} nginx:nginx /etc/certs/nlgld.dn42/*
            # Something fucky is going on here...
            ${lib.getExe' pkgs.systemd "systemctl"} stop nginx
            ${lib.getExe' pkgs.systemd "systemctl"} start nginx
            exit 0
          '';
        };
      };
    })
  ];
}
