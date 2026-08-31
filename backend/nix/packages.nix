{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs { inherit system; };

      purs-nix = inputs.purs-nix { inherit system; };

      ps = purs-nix.purs {
        dependencies = [
          "ursi.debug"
          "effect"
          "prelude"
        ];

        test-dependencies = [
          "test-unit"
        ];

        dir = ./..;
      };
    in
    {
      _module.args = {
        inherit pkgs ps purs-nix;
        ps-tools = inputs.ps-tools.legacyPackages.${system};
      };

      packages.default = ps.output { };
    };
}
