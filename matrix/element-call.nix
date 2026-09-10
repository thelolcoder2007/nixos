{ pkgs, ... }:

let
  element-call-config-json = pkgs.writeTextFile {
    name = "element-call config.json";
    text = ''
      {
        "default_server_config": {
          "m.homeserver": {
            "base_url": "https://matrix.dapperepoging.nl",
            "server_name": "matrix.dapperepoging.nl:443"
          }
        },
        "features": {
          "feature_use_device_session_member_events": true,
          "feature_group_calls_without_video_and_audio": false
        },
        "ssla": "https://static.element.io/legal/element-software-and-services-license-agreement-uk-1.pdf",
        "app_prompt": true,
        "media_devices": {
          "enable_audio": true,
          "enable_video": true
        },
        "livekit": {
          "livekit_service_url": "https://livekit.dapperepoging.nl/livekit/sfu"
        }
      }
    '';
    destination = "/config.json";
  };
  element-call-package = pkgs.element-call;

  element-call-configured = pkgs.symlinkJoin {
    name = "element-call-configured";
    paths = [ element-call-package ];
    postBuild = ''
      # Inject the config file into the root of the new derivation
      #rm $out/config.json
      ln -s ${element-call-config-json}/config.json $out/config.json
    '';
  };
in
{
  services.nginx = {
    enable = true;
    virtualHosts."call-2.dapperepoging.nl" = {
      globalRedirect = null;
      root = element-call-configured;
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
