{ pkgs, ... }:

let
  clientScript = pkgs.fetchurl {
    url = "https://dn42.g-load.eu/about/certificate-authority/client.sh";
    hash = "sha256-1/QOigfUcc6LUGM9/Ud7CRo9odYSBtfEjDUfOYDxBT0=";
  };
in
{
  sops.secrets."dn42_secret" = {
    path = "/run/dn42-cert/token.txt";
  };
  systemd.services.nginx.after = [ "dn42-cert.service" ];
  systemd.services.dn42-cert = {
    description = "Fetch DN42 Certificate using client.sh";

    after = [
      "network-online.target"
      "sops-nix.service"
    ];
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

      ExecStart = pkgs.writeShellScript "run-dn42-script" ''
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
