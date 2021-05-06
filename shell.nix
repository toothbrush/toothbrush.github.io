# Use latest stable Nix channel
{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-20.09.tar.gz") { } }:

pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = [
    pkgs.pandoc
    pkgs.python3
  ];
}
