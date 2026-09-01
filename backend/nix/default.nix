_: {
  imports = [
    ../../nix/systems.nix
    ./packages.nix
    ./checks.nix
    ./devShells.nix
    ./pre-commit.nix
    ./treefmt.nix
  ];
}
