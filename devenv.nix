{
  pkgs,
  lib,
  config,
  ...
}: {
  # https://devenv.sh/packages/
  packages = [
    pkgs.hugo
    pkgs.dart-sass
    pkgs.nixd
    pkgs.treefmt
    pkgs.alejandra
    pkgs.go-task
  ];

  # https://devenv.sh/reference/options/
  treefmt = {
    enable = true;
    config.programs = {
      alejandra.enable = true;
    };
  };
}
