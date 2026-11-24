{ lib, host, ... }:

let
  inherit (host)
    vmwareHost
    qemuHost
    guid_root
    guid_boot
    ;
  base = {
    assertions = [
      {
        assertion = !(vmwareHost && qemuHost);
        message = "Configuration Error: One host cannot run on both VMware and QEMU. Please set at most one of the options vmwareHost or qemuHost to true.";
      }
    ];
    boot = {
      initrd.availableKernelModules = [
        "ata_piix"
        "sd_mod"
        "sr_mod"
      ];
      initrd.kernelModules = [ ];
      extraModulePackages = [ ];
    };

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/${guid_root}";
        fsType = "btrfs";
      };
      "/nix" = {
        device = "/dev/disk/by-uuid/${guid_root}";
        fsType = "btrfs";
        options = [ "subvol=nix" ];
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/${guid_boot}";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };
    };
  };

  vmwareModules = lib.optionalAttrs vmwareHost {
    virtualisation.vmware.guest.enable = true;
    boot.initrd.availableKernelModules = [
      "vmw_pvscsi"
    ];
  };
  qemuModules = lib.optionalAttrs qemuHost {
    services.qemuGuest.enable = true;
    boot = {
      initrd.availableKernelModules = [
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];
      kernelModules = [ "kvm-intel" ];
    };
  };

in
base // qemuModules // vmwareModules
