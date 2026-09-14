{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./sops.nix
  ];
  sops.secrets."thomas_userpassword" = {
    sopsFile = ../secrets/common.yml;
    neededForUsers = true;
  };
  sops.secrets."root_userpassword" = {
    sopsFile = ../secrets/common.yml;
    neededForUsers = true;
  };

  users = {
    defaultUserShell = lib.mkForce pkgs.bash;
    mutableUsers = false;
    users = {
      thomas = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/7b7OH03t60heXNS8OUpmNVgOhUFwcLLQmP0gBC1SQ thomas@HPTHOMAS-ARCH"
        ];
        hashedPasswordFile = config.sops.secrets."thomas_userpassword".path;
      };
      root.hashedPasswordFile = config.sops.secrets."root_userpassword".path;
    };
  };
}
