{ inputs, ... }:
{
  perSystem =
    { system, lib, ... }:
    {
      treefmt.programs = {
        nixfmt = {
          enable = true;
          includes = [ "*.nix" ];
        };
        oxfmt = {
          enable = true;
          includes = [
            "*.json"
            "*.jsonc"
            "*.json5"
            "*.md"
            "*.mdx"
            "*.yaml"
            "*.yml"
          ];
        };
      };

      treefmt.settings.formatter.purs-tidy = {
        command = lib.getExe' inputs.ps-tools.legacyPackages.${system}.for-0_15.purs-tidy "purs-tidy";
        options = [ "format-in-place" ];
        includes = [ "*.purs" ];
      };
    };
}
