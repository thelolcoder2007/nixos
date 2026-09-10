{
  lib,
  host,
  ...
}:

assert
  !(host.vmwareHost && host.qemuHost)
    "Configuration Error: Cannot run both VMware and QEMU hosts simultaneously. Please set one of the host parameters (vmwareHost or qemuHost) to false.";
let
  inherit (host)
    vmwareHost
    qemuHost
    guid_root
    guid_boot
    ;
  base = {
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
      ];
      kernelModules = [ "kvm-intel" ];
    };
  };

in
	base // qemuModules // vmwareModules
