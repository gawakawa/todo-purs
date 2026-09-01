_: {
  perSystem =
    {
      config,
      pkgs,
      frontend,
      backend,
      ...
    }:
    let
      mkShell =
        { ps, purs-nix }:
        pkgs.mkShell {
          buildInputs = config.pre-commit.settings.enabledPackages ++ [
            (ps.command { })
            purs-nix.purescript
            pkgs.nodejs_24
          ];
          shellHook = ''
            ${config.pre-commit.shellHook}
          '';
        };
    in
    {
      devShells = {
        default = pkgs.mkShell {
          buildInputs = config.pre-commit.settings.enabledPackages;
          shellHook = ''
            ${config.pre-commit.shellHook}
          '';
        };
        frontend = mkShell frontend;
        backend = mkShell backend;
      };
    };
}
