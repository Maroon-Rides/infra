module "install" {
  source = "github.com/nix-community/nixos-anywhere//terraform/install?ref=1.13.0"

  flake       = "${abspath("${path.module}/../../../nixos")}#${var.hostname}"
  target_host = var.target_host

  // The workstation is aarch64-darwin and cannot build an x86_64-linux closure.
  build_on_remote = true

  // Only a new instance id reinstalls; `tofu apply -replace` forces it.
  instance_id = var.instance_id
}
