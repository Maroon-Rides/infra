{ ... }:

{
  boot.kernelModules = [
    "loop"
    "dm_thin_pool"
  ];

  # Matched by the `std` MiroirNodeGroup
  services.k3s.extraFlags = [
    "--node-label=storage.miroir.home-operations.com/class=std"
  ];

  # Volume images hold databases; copy-on-write under them multiplies every sync.
  systemd.tmpfiles.rules = [
    "d /var/lib/miroir/volumes 0755 root root -"
    "h /var/lib/miroir/volumes - - - - +C"
  ];
}
