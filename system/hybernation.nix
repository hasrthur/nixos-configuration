{ ... }:

{
  # https://sawyershepherd.org/post/hibernating-to-an-encrypted-swapfile-on-btrfs-with-nixos/
  # findmnt -no UUID -T /.swapvol/swapfile
  # wget https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c
  # gcc btrfs_map_physical.c -o btrfs_map_physical
  # sudo ./btrfs_map_physical /swap/swapfile
  # Find the first physical offset provided and divide it by the page size of your system. Usually this is 4096, but you can also find it with:
  # getconf PAGESIZE


  boot = {
    resumeDevice = "/dev/disk/by-uuid/84e2cbec-2fb2-4797-9bac-4389961ef4d9";
    kernelParams = [ "resume_offset=18883840" ];
  };
}