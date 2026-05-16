{ inputs, lib, ... }:
{
  imports = [ inputs.flake-parts.flakeModules.modules ];

  options.flake.factory = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = { };
  };
}
