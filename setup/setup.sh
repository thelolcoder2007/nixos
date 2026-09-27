#!/usr/bin/env bash

sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./btrfs-subvolumes.nix
sudo mkdir -p /nix/persist/var/lib/sops-nix/
sudo cp /etc/ssh/ssh_host_ed25519_key /nix/persist/var/lib/sops-nix/key.txt
sudo chmod 0400 /nix/persist/var/lib/sops-nix/key.txt
sudo cp /nix/persist /mnt/nix -r
sudo nixos-generate-config --root /mnt
git clone https://thelolcoder2007/nixos /mnt/etc/nixos/nixos
less /mnt/etc/nixos/nixos/README.md
