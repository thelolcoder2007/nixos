{ pkgs, ... }:

let
  cinny-config-json = pkgs.writeTextFile {
    name = "Cinny config.json";
    text = ''
      {
        "defaultHomeserver": 0,
        "homeserverList": ["matrix.dapperepoging.nl"],
        "allowCustomHomeservers": false,
        "elementCallUrl": null,

        "disableAccountSwitcher": false,
        "hideUsernamePasswordFields": false,

        "slidingSync": {
          "enabled": true
        },

        "featuredCommunities": {
          "openAsDefault": false,
          "spaces": [ ],
          "rooms": [ ],
          "servers": ["dapperepoging.nl", "utwente.io", "matrix.org"]
        },

        "hashRouter": {
          "enabled": false,
          "basename": "/"
        }
      }

    '';
    destination = "/config.json";
  };

  # Add configuration file to Sable
  cinny-configured = pkgs.symlinkJoin {
    name = "cinny-configured";
    paths = [ pkgs.cinny-unwrapped ];
    postBuild = ''
      # Inject the config file into the root of the new derivation
      rm $out/config.json
      ln -s ${cinny-config-json}/config.json $out/config.json
    '';
  };
in
{
  services.nginx = {
    enable = true;
    virtualHosts."cinny-2.chat.dapperepoging.nl" = {
      globalRedirect = null;
      root = cinny-configured;
      locations."/" = {
        index = "index.html";
        tryFiles = "$uri $uri/ /index.html";
      };
      locations."^/config.json" = {
        tryFiles = "$uri /config.json/config.json";
      };
    };
  };
}
