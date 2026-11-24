{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  presets = import (inputs.steamcmd-servers + "/presets.nix") { inherit lib; };
in
{
  imports = [ ../common.nix ];
  services.steamcmd-servers = {
    enable = true;
    servers.rustds = lib.recursiveUpdate presets.rust {
      enable = true;
      executableArgs = [
        "-batchmode"
        "-logfile"
        "+server.port 28015"
        "+rcon.port 28016"
        "+server.level Procedural Map"
        "+server.worldsize 4000"
        "+server.maxplayers 100"
        "+server.hostname \"NixOS Rust Server\""
      ];
      ports = { };
      resources.memoryLimit = "8G";
    };
  };
  networking.firewall.allowedTCPPorts = [
    28015
    28016
  ];
  networking.firewall.allowedUDPPorts = [
    28015
    28016
  ];
  programs.nix-ld = {
    enable = lib.mkForce true;
    libraries = with pkgs; [
      libc
      libdecor
      pango
      cairo
      glib
      wayland
      dbus
    ];
  };
}
