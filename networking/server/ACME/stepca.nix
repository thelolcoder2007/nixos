{
  config,
  lib,
  pkgs,
  ...
}:
let
  initStepca-sh = pkgs.writeShellScript "initstepca.sh" ''
    cd /var/lib/step-ca
    [ -e /var/lib/step-ca/root/ca.crt ] || [ -e /var/lib/step-ca/im/im.crt ] || [ -e /var/lib/step-ca/im.key ] || exit 1
    ${lib.getExe' pkgs.step-cli "step"} certificate create --profile=root-ca "Dapperepoging Root CA" ca.crt ca.key --no-password --insecure
    ${lib.getExe' pkgs.step-cli "step"} certificate create --profile=intermediate-ca "Dapperepoging Intermediate CA" im.crt im.key --ca=./ca.crt --ca-key=./ca.key
    mkdir -p root im
    mv ca.* root/
    mv im.* im/
    chown -R step-ca:nginx .
  '';
in
{
  users.users.step-ca.extraGroups = [ "nginx" ];
  systemd.tmpfiles.rules = [
    "d /var/lib/step-ca/ 0750 step-ca nginx 0 -"
  ];
  systemd.services.init-stepca = {
    serviceConfig = {
      User = config.users.users.step-ca.name;
      Group = config.users.groups.step-ca.name;
      Type = "oneshot";
      ExecStart = initStepca-sh;
    };
    wantedBy = [ "multi-user.target" ];
    before = [ "step-ca.service" ];
  };
  services.step-ca = {
    enable = true;
    port = 7217;
    address = "[::1]";
    openFirewall = true;

    settings = {
      root = "/var/lib/step-ca/root/ca.crt";
      crt = "/var/lib/step-ca/im/im.crt";
      key = "/var/lib/step-ca/im/im.key";
      dnsNames = [
        "certs.16.dapperepoging.nl"
        config.networking.interfaces."ens192".ipv4
        config.networking.interfaces."ens192".ipv6
      ];

      db = {
        type = "badgerv2";
        dataSource = "/var/lib/step-ca/db";
      };

      authority = {
        disableIssuedAtCheck = false;
        claims = {
          minTLSCertDuration = "5m";
          maxTLSCertDuration = "24h";
          defaultTLSCertDuration = "24h";
          disableRenew = false;
          allowRenewalAfterExpi = false;
        };

        policy.x509 = {
          allow.dns = [
            "*.dapperepoging.nl"
            "*.16.dapperepoging.nl"
          ];
          allowWildcardNames = true;
        };
        enableSSHCA = false;
        provisioners = [
          {
            # https://smallstep.com/docs/step-ca/provisioners/#example-3
            type = "ACME";
            name = "acme";
            forceCN = true;
            challenges = [
              "http-01"
            ];
          }
        ];
      };
      tls = {
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        ];
        minVersion = 1.2;
        maxVersion = 1.3;
        renegotiation = false;
      };
    };
  };
}
