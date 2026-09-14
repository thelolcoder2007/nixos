{
  config,
  lib,
  ...
}:

{
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];
  imports = [
    ../networking/server/HTTP/defaults.nix
    ../networking/server/HTTP/options.nix
  ];
  services.maubot = {
    enable = true;
    settings = {
      homeservers."dapperepoging.nl".url = "https://matrix.dapperepoging.nl";
      admins = {
        "erents" = "$2b$12$CfwiGatn.xmfDaKnGzKZAOO0ALlk/Z0jDNviBofYpIRzDHTuwXFgC";
        "root" = "";
      };
    };
    plugins =
      with config.services.maubot.package.plugins;
      allOfficialPlugins
      ++ [
        # keep-sorted start
        choose
        giphy
        hasswebhookbot
        hateheif
        # help # Fetch gives HTTP 522
        invite
        join
        metric
        random-quote
        tex
        timer
        # keep-sorted end
      ];
  };
  services.nginx.virtualHosts."maubot.dapperepoging.nl" = {
    locations."${config.services.maubot.settings.server.ui_base_path}" = {
      proxyPass = "http://127.0.0.1:${lib.toString config.services.maubot.settings.server.port}$request_uri";
      proxyWebsockets = true;
    };
  };
  x.nginx.virtualHosts."maubot.dapperepoging.nl".snakeoilHost = true;
}
