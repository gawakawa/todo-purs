_: {
  perSystem =
    {
      config,
      pkgs,
      ps,
      purs-nix,
      ...
    }:
    let
      devPackages = config.pre-commit.settings.enabledPackages ++ [
        (ps.command { })
        purs-nix.purescript
        pkgs.nodejs_24
      ];
    in
    {
      devShells.default = pkgs.mkShell {
        buildInputs = devPackages;
        shellHook = ''
          ${config.pre-commit.shellHook}
        '';
      };
    };
}
