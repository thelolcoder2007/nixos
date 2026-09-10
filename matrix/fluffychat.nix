{ pkgs, ... }:

let
  fluffychat-config-json = pkgs.writeTextFile {
    name = "Fluffy.chat config.json";
    text = ''
      {
        "defaultHomeserver": "matrix.dapperepoging.nl",
        "welcomeText": "Welcome to Fluffychat!"
      }
    '';
  };

  # Add configuration file to Sable
  fluffychat-configured = pkgs.symlinkJoin {
    name = "fluffychat-configured";
    paths = [ pkgs.fluffychat-web ];
    postBuild = ''
      # Inject the config file into the root of the new derivation
      ln -s ${fluffychat-config-json} $out/config.json
    '';
  };
in
{
  imports = [
    ../webserver/nginx-base.nix
  ];

  services.nginx.virtualHosts."fluffy-2.chat.dapperepoging.nl" = {
    locations."/" = {
      index = "index.html";
      tryFiles = "$uri $uri/ /index.html";
    };
    locations."^/config.json$" = {
      tryFiles = "$uri /config.json/config.json";
    };
    root = fluffychat-configured;
  };
}
