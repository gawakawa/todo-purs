_: {
  imports = [
    ./systems.nix
    ../frontend/nix/packages.nix
    ../backend/nix/packages.nix
    ./checks.nix
    ./devShells.nix
    ./pre-commit.nix
    ./treefmt.nix
  ];
}
