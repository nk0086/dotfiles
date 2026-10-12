{
  description = "Home Manager configurations for macOS and Linux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    mkHome = system: platform:
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {inherit system;};
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home-manager/home.nix
          platform
        ];
      };
  in {
    homeConfigurations = {
      # Keep the existing macOS entry point.
      myHomeConfig = mkHome "aarch64-darwin" ./home-manager/platforms/darwin.nix;
      linuxHomeConfig = mkHome "x86_64-linux" ./home-manager/platforms/linux.nix;
      linuxArmHomeConfig = mkHome "aarch64-linux" ./home-manager/platforms/linux.nix;
    };
  };
}
