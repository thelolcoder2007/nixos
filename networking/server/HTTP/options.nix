{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkOption mkEnableOption types;
  cfg = config.x.nginx.virtualHosts;
in
{
  options.x.nginx.virtualHosts = mkOption {
    type = types.attrsOf (
      types.submodule {
        options = {
          prodHost = mkEnableOption "Enable this host to run production (aka ask for ACME certs)";
          snakeoilHost = mkEnableOption "Use snakeoil HTTPS certificates for this host";
        };
      }
    );
  };
  config.assertions = [
    {
      assertion = lib.all (vhost: !(vhost.snakeoilHost && vhost.prodHost)) (
        lib.attrValues config.x.nginx.virtualHosts
      );
      message = "A virtualHost cannot have both snakeoilHost and enableACME set to true.";
    }
  ];
  config = {
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
        sslCertificate = "${pkgs.path}/nixos/tests/common/acme/server/acme.test.cert.pem";
        sslCertificateKey = "${pkgs.path}/nixos/tests/common/acme/server/acme.test.key.pem";
      }
    );
  };

}
