{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: let
  username = "nk";
in {
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      inputs.neovim-nightly-overlay.overlays.default
    ];
  };

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    packages = with pkgs; [
      git
      curl
      alejandra
      eza
      neovim
    ];
  };

  programs.home-manager.enable = true;
}
