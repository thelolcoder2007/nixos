{ config, ... }:
{
  imports = [
    ./vert-sh-pkg/options.nix
    ../networking/server/HTTP/defaults.nix
    ../networking/server/HTTP/options.nix
  ];
  services.vert-sh.enable = true;

  services.nginx.virtualHosts."vert-sh.dapperepoging.nl" = {
    root = config.services.vert-sh.package;
    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri/ /index.html";
    };
  };
  x.nginx.virtualHosts."vert-sh.dapperepoging.nl".snakeoilHost = true;
}
