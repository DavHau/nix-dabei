{ pkgs, ... }:
{
  boot.initrd.kernelModules = [ "virtio" "virtio_pci" "virtio_net" "virtio_rng" "virtio_blk" "virtio_console" ];
  not-os.nix = true;
  not-os.simpleStaticIp = true;
  networking.nameservers = ["1.1.1.1"];
  environment.systemPackages = [ pkgs.utillinux ];
  environment.etc = {
    "ssh/authorized_keys.d/root" = {
      text = ''
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLopgIL2JS/XtosC8K+qQ1ZwkOe1gFi8w2i1cd13UehWwkxeguU6r26VpcGn8gfh6lVbxf22Z9T2Le8loYAhxANaPghvAOqYQH/PJPRztdimhkj2h7SNjP1/cuwlQYuxr/zEy43j0kK0flieKWirzQwH4kNXWrscHgerHOMVuQtTJ4Ryq4GIIxSg17VVTA89tcywGCL+3Nk4URe5x92fb8T2ZEk8T9p1eSUL+E72m7W7vjExpx1PLHgfSUYIkSGBr8bSWf3O1PW6EuOgwBGidOME4Y7xNgWxSB/vgyHx3/3q5ThH0b8Gb3qsWdN22ZILRAeui2VhtdUZeuf2JYYh8L
      '';
      mode = "0444";
    };
  };
}
