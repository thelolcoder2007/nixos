{ config, ... }:
{
  imports = [
    ../../../base/sops.nix
  ];
  sops.secrets."stepca-intermediate-password" = {
    owner = "step-ca";
    group = "step-ca";
  };
  users.users.step-ca.extraGroups = [ "nginx" ];
  services.step-ca = {
    enable = true;
    port = 443;
    address = "[::]";
    openFirewall = true;

    intermediatePasswordFile = config.sops.secrets."stepca-intermediate-password".path;
    settings = {
      root = "/var/lib/step-ca/root/ca.crt";
      crt = "/var/lib/step-ca/im/im.crt";
      key = "/var/lib/step-ca/im/im.key";
      dnsNames = [
        "certs.16.dapperepoging.nl"
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
