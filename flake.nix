{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dns = {
      url = "github:kirelagin/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steamcmd-servers = {
      url = "github:kagurazaka-ayano/steamcmd-servers";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      self,
      treefmt-nix,
      ...
    }@inputs:
    {
      # for `nix fmt`
      formatter.x86_64-linux =
        (treefmt-nix.lib.evalModule nixpkgs.outputs.legacyPackages.x86_64-linux ./base/treefmt.nix)
        .config.build.wrapper;
      # for `nix flake check`
      checks.x86_64-linux.formatting = (treefmt-nix.lib.evalModule nixpkgs.outputs.legacyPackages.x86_64-linux ./base/treefmt.nix).config.build.check self;
      nixosConfigurations =
        let
          emulatedHost = "hermes";
          hosts = {
            # Apollo makes music. It will be my media server (if I need one)
            "apollo" = {
              guid_root = "0";
              guid_boot = "0";
              vmwareHost = true;
              qemuHost = false;
            };
            # Athena is the goddess of war and knowledge. It will be my buildserver
            # and nixos reference host.
            "athena" = {
              guid_root = "0";
              guid_boot = "0";
              vmwareHost = true;
              qemuHost = false;
            };
            # Hera sees everything Zeus does (which is mostly sleeping with other women)
            # Therefore it is my monitoring server and does the home-assistant stuff
            "hera" = {
              guid_root = "0";
              guid_boot = "0";
              vmwareHost = true;
              qemuHost = false;
            };
            # Hermes brings messages to everybody.
            # Therefore it runs my Matrix homeserver and the Matrix and IRC clients.
            "hermes" = {
              guid_root = "0";
              guid_boot = "0";
              vmwareHost = true;
              qemuHost = false;
            };
            # Poseidon talks with a lot of creatures others can't understand.
            # Therefore it runs the BGP for DN42 (underwater)
            "poseidon" = {
              guid_root = "2b92fb35-d027-4244-8c68-c01e62d198dd";
              guid_boot = "8383-403B";
              vmwareHost = true;
              qemuHost = false;
            };
            # The nixos tryout server. I use it to test hosts, which means that I build it to be a lot of different hosts
            # It gets a lot of "foreigners", "xenoi", in its body.
            "xenoi" = {
              guid_root = "bce8673e-6588-4782-bf43-c2b351da947d";
              guid_boot = "8ED8-E9E1";
              vmwareHost = false;
              qemuHost = true;
            };
            # Zeus is the leader of the gods. It will serve DNS, DHCPv4,
            # and will generally be owner of the subnet 10.0.116.0/24
            "zeus" = {
              guid_root = "0";
              guid_boot = "0";
              vmwareHost = true;
              qemuHost = false;
            };
          };
        in
        nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames hosts) (
          host:
          nixpkgs.lib.nixosSystem {
            modules = [
              ./hosts/${host}.nix
              (import ./hosts/hardware-configuration.nix {
                inherit (nixpkgs) lib;
                host = hosts.${host};
              })
            ];
            specialArgs = {
              inherit inputs;
              emulatedHost = "";
            };
          }
        )
        // {
          xenoi = nixpkgs.lib.nixosSystem {
            modules = [
              ./hosts/xenoi.overrides.nix
              ./hosts/${emulatedHost}.nix
              (import ./hosts/hardware-configuration.nix {
                inherit (nixpkgs) lib;
                host = hosts.xenoi;
              })
            ];
            specialArgs = {
              inherit inputs;
              inherit emulatedHost;
            };
          };
        };
    };
}
