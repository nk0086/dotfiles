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

  imports = [
    ./programs/zsh.nix
    ./programs/bat.nix
    ./programs/eza.nix
    ./programs/gh.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";

    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";

    packages = with pkgs; [
      # base packages
      git
      curl
      fzf
      neovim
      ranger
      starship
      gh

      # formatting tools
      alejandra # nix

      # extensions
      bat
      eza
      ripgrep
      zoxide
    ];
  };

  programs.home-manager.enable = true;
  programs.starship.enable = true;
}
