{
  ...
}:

let
  addresses = import ./addresses.nix;
in
{
  imports = [
    ./hardware-configuration.nix
    ./disk-config.nix
    ../../lib/base-packages.nix
    ../../lib/maroonrides.nix
    ../../lib/garbage-collect.nix
    ../../lib/tailscale.nix
    ../../lib/k3s.nix
    ../../lib/miroir.nix
  ];

  system.stateVersion = "26.05";

  # Networking/Clock
  networking.hostName = "prod-server";
  time.timeZone = "America/Chicago";

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;

  services.tailscale.extraUpFlags = [
    "--advertise-tags=tag:prod,tag:nixos"
  ];

  services.k3s.extraFlags = [
    # --node-ip must be pinned: otherwise k3s auto-detects a dual-stack node and
    # silently drops the IPv4-only --node-external-ip, leaving no ExternalIP.
    "--node-ip=${addresses.ipv4}"
    "--node-external-ip=${addresses.ipv4}"
  ];

  # envoy-ingress claims the public IP as a Service externalIP
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.fail2ban.enable = true;
}
