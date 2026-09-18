{ config, lib, ... }:
{
  imports = [
    ../HTTP/defaults.nix
    ../HTTP/options.nix
    ../../../base/sops.nix
  ];

  services.bird-lg = {
    proxy = {
      enable = true;
      listenAddresses = [
        "172.23.99.254:8000"
        "[fda7:54c1:4932::]:8000"
      ];
    };
    frontend = {
      enable = true;
      servers = [ "poseidon" ];
      domain = "nlgld.dn42";
      listenAddresses = [
        "172.23.99.254:5000"
        "[fda7:54c1:4932::]:5000"
      ];
    };
  };
  services.nginx = {
    virtualHosts."lg.nlgld.dn42".locations."/".proxyPass = "http://BIRD-LG-backend";
    upstreams."BIRD-LG-backend".servers =
      lib.genAttrs config.services.bird-lg.frontend.listenAddresses
        (_: { });
  };
  x.nginx.virtualHosts."lg.nlgld.dn42".DN42Host = true;
  networking.firewall = {
    allowedUDPPorts = [ 443 ];
    allowedTCPPorts = [
      80
      443
    ];
  };
}
