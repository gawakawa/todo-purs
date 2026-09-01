{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      purs-nix = inputs.purs-nix { inherit system; };

      ps = purs-nix.purs {
        dependencies = [
          "ursi.debug"
          "effect"
          "prelude"
          "httpurple"
        ];

        test-dependencies = [
          "test-unit"
        ];

        dir = ./..;
      };
    in
    {
      _module.args.backend = { inherit ps purs-nix; };

      packages.backend = ps.output { };
    };
}
