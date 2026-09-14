{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    types
    ;
  mkDisableOption = lib.mkEnabledOption;
in
{
  options = {
    services.vert-sh = {
      enable = mkEnableOption "Vert.sh";

      package = mkOption {
        type = types.package;
        default = pkgs.callPackage ./package.nix {
          configuration = config.services.vert-sh.config;
          bun2nix = inputs.bun2nix.packages.x86_64-linux.default;
        };
        description = "Vert.sh package to run";
      };
      config = {
        analytics = {
          hostname = mkOption {
            type = types.str;
            default = "";
            example = "localhost:5173";
            description = "The hostname used for analytics tracking (currently only used by Plausible)";
          };
          URL = mkOption {
            type = types.str;
            default = "";
            description = "https://plausible.example.com";
          };
        };
        vertd-url = mkOption {
          type = types.str;
          default = "https://vertd.vert.sh";
          description = "URL of the vertd daemon for video conversion (default: official VERT instance)";
        };
        disable-external-requests = mkDisableOption "Set to true to disable all external requests. Useful for privacy-focused deployments or air-gapped environments";
        disable-failure-blocks = mkDisableOption "Set to true to disable blocking video conversions of an uploaded file when repeated failures occur within an hour. Useful for local deployments where secure context (HTTPS) may not be available - required for calculating file hashes of videos to block temporarily.";
      };
    };
  };
}
