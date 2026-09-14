{ pkgs, ... }:
let
  conf = {
    defaultHomeserver = 0;
    homeserverList = [ "matrix.dapperepoging.nl" ];
    allowCustomHomeservers = false;
    elementCallUrl = "https://call.dapperepoging.nl";

    disableAccountSwitcher = false;
    hideUsernamePasswordFields = false;

    pushNotificationDetails = {
      pushNotifyUrl = "https://sygnal.sable.moe/_matrix/push/v1/notify";
      vapidPublicKey = "BCnS4SbHjeOaqVFW4wjt5xDt_pYIL62qMzKePfYF9fl9PQU14RieIaObh7nLR_9dQf4sykZa-CTrcjkgMIE1mcg";
      webPushAppID = "moe.sable.app.sygnal";
    };

    themeCatalogBaseUrl = "https://raw.githubusercontent.com/SableClient/themes/main/";
    themeCatalogApprovedHostPrefixes = [ "https://raw.githubusercontent.com/SableClient/themes/" ];

    slidingsync.enable = true;

    featuredCommunities = {
      openAsDefault = false;
      spaces = [ ];
      rooms = [ ];
      servers = [
        "dapperepoging.nl"
        "utwente.io"
        "matrix.org"
      ];

      gifs = {
        proxyUrl = "gifs.sable.moe";
        klipyApiKey = "IfeIBlDMvq0av2BcKPDuxwRqbnYRbS90yNqFHEkK2Ja207tkR5nssh3NIlJRCr76";
      };
    };

    hashRouter = {
      enabled = false;
      basename = "/";
    };
  };
  sable = pkgs.callPackage ./pkg-sable/options.nix {
    inherit (pkgs) sable;
    inherit conf;
  };
in
{
  services.nginx = {
    enable = true;
    virtualHosts."sable-2.chat.dapperepoging.nl" = {
      root = sable;
      locations."/" = {
        index = "index.html";
        tryFiles = "$uri $uri/ /index.html";
      };
      locations."^/config.json" = {
        tryFiles = "$uri /config.json/config.json";
      };
    };
  };
  x.nginx.virtualHosts."sable-2.chat.dapperepoging.nl".snakeoilHost = true;
}
