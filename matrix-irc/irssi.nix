{ config, pkgs, ... }:

{
  imports = [
    ../base/sops.nix
  ];
  sops.secrets."irssi-config" = {
    owner = config.users.users.thomas.name;
    path = "/home/thomas/.irssi/config";
  };
  environment.systemPackages = with pkgs; [ irssi ];
}
