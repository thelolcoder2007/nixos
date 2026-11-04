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
in
{
  options = {
    services.vert-sh = {
      enable = mkEnableOption "Vert.sh";

      package = mkOption {
        type = types.package;
        default = pkgs.callPackage ./package.nix {
          bun2nix = inputs.bun2nix.packages.x86_64-linux.default;
          env = config.services.vert-sh.config;
        };
        description = "Vert.sh package to run";
      };
      config = {
        HOSTNAME = mkOption {
          type = types.str;
          default = "";
          example = "localhost:5173";
          description = "The hostname used for analytics tracking (currently only used by Plausible)";
        };
        PLAUSIBLE_URL = mkOption {
          type = types.str;
          default = "";
          example = "https://plausible.example.com";
          description = "URL for your Plausible Analytics instance (leave empty to disable analytics)";
        };
        VERTD_URL = mkOption {
          type = types.str;
          default = "https://vertd.vert.sh";
          description = "URL of the vertd daemon for video conversion (default: official VERT instance)";
        };
        PUB_DISABLE_FAILURE_BLOCKS = mkOption {
          type = types.str;
          default = "false";
          example = "true";
          description = "Set to true to disable blocking video conversions of an uploaded file when repeated failures occur within an hour. Setting to false is only recommended for production deployments where secure context (HTTPS) is available, which is required for calculating file hashes of videos to block temporarily.";
        };
        DISABLE_ALL_EXTERNAL_REQUESTS = mkOption {
          type = types.str;
          default = "false";
          example = "true";
          description = "Set to true to disable all external requests (vertd, Stripe, Plausible, etc.). Useful for privacy-focused deployments or air-gapped environments. Note: the ffmpeg worker is still downloaded via a CDN (cdn.jsdelivr.net)";
        };
      };
    };
  };
}
