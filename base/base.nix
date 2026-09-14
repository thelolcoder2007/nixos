{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./clamav.nix
    ./sops.nix
    ./users.nix
  ];
  sops = {
    # Github plz no ratelimit tyyy
    templates."nix-github-token.env".content = ''
      access-tokens = github.com=${config.sops.placeholder.github_token}
    '';
    secrets = {
      "privkey" = {
        sopsFile = ../secrets/${config.networking.hostName}.yml;
        path = "/etc/ssh/ssh_host_ed25519_key";
      };
      "pubkey" = {
        sopsFile = ../secrets/${config.networking.hostName}.yml;
        path = "/etc/ssh/ssh_host_ed25519_key.pub";
        mode = "0444";
      };
      github_token.sopsFile = ../secrets/common.yml;
    };
  };

  nix = {
    extraOptions = ''
      !include ${config.sops.templates."nix-github-token.env".path}
    '';
    settings = {
      trusted-users = [
        "thomas"
      ];
      cores = 0;
      max-jobs = "auto";
      experimental-features = [
        "nix-command"
        "flakes"
        "pipe-operators"
      ];
    };
  };

  environment = {
    variables = {
      "NH_FLAKE" = "/etc/nixos/nixos-repository";
    };
    systemPackages = with pkgs; [
      # keep-sorted start
      bat
      btop
      comma
      curl
      dig
      fastfetch
      file
      gh
      git
      htop
      iftop
      iotop
      nano
      nh
      pciutils
      screen
      tcpdump
      traceroute
      usbutils
      vim
      wget
      # keep-sorted end
    ];
  };

  boot = {
    loader.grub = {
      # Use GRUB
      enable = true;
      device = "nodev"; # Boot EFI please
      efiSupport = true;
      efiInstallAsRemovable = true; # Just because this is easier to boot from on virtualized hosts
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl."kernel.task_delayacct" = 1; # For iotop
  };

  time.timeZone = "Europe/Amsterdam";

  system.stateVersion = "26.11";

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
