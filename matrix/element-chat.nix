{ pkgs, ... }:

let
  element-config-json = pkgs.writeTextFile {
    name = "Element web config.json";
    text = ''
      {
        "default_server_config": {
          "m.homeserver": {
            "base_url": "https://matrix.dapperepoging.nl",
            "server_name": "matrix.dapperepoging.nl"
          },
          "m.identity_server": {
            "base_url": "https://vector.im"
          }
        },
        "disable_custom_urls": true,
        "disable_guests": true,
        "disable_login_language_selector": false,
        "disable_3pid_login": false,
        "force_verification": false,
        "brand": "Element",
        "integrations_ui_url": "https://scalar.vector.im/",
        "integrations_rest_url": "https://scalar.vector.im/api",
        "integrations_widgets_urls": [
          "https://scalar.vector.im/_matrix/integrations/v1",
          "https://scalar.vector.im/api",
          "https://scalar-staging.vector.im/_matrix/integrations/v1",
          "https://scalar-staging.vector.im/api"
        ],
        "default_widget_container_height": 280,
        "default_country_code": "NL",
        "show_labs_settings": true,
        "features": {},
        "default_federate": true,
        "default_theme": "dark",
        "room_directory": {
          "servers": [
            "dapperepoging.nl",
            "utwente.io",
            "matrix.org"
          ]
        },
        "setting_defaults": {
          "breadcrumbs": true
        },
        "element_call": {
          "url": "https://call.element.io",
          "brand": "Element Call"
        },
        "map_style_url": "https://api.maptiler.com/maps/streets/style.json?key=fU3vlMsMn4Jb6dnEIFsx"
      }
    '';
    destination = "/config.json";
  };
  elementPackage = pkgs.element-web;

  # Add configuration file to Sable
  element-web-configured = pkgs.symlinkJoin {
    name = "element-web-configured";
    paths = [ elementPackage ];
    postBuild = ''
      # Inject the config file into the root of the new derivation
      rm $out/config.json
      ln -s ${element-config-json}/config.json $out/config.json
    '';
  };
in
{
  services.nginx = {
    enable = true;
    virtualHosts."element-2.chat.dapperepoging.nl" = {
      globalRedirect = null;
      root = element-web-configured;
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
