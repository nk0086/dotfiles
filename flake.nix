{
  description = "Minimal package definition for aarch64-darwin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      rust-overlay,
      ...
    }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ rust-overlay.overlays.default ];
      };
      lib = nixpkgs.lib;
    in
    {
      apps.${system} = {
        # nix run .#update
        update = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "update-script" ''
              set -e
              echo "Updating flake ... "
              nix flake update
              echo "Updating home-manager ... "
              nix run nixpkgs#home-manager -- switch --flake .#myHomeConfig
              echo "Update complete!"
            ''
          );
        };

        # nix run .#sync
        sync = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "sync-script" ''
              set -e
              echo "Syncing home-manager configuration..."
              nix run nixpkgs#home-manager -- switch --flake .#myHomeConfig
              echo "Sync complete! Config changes applied."
            ''
          );
        };

        # nix run .#link
        # dotfiles内のnvimやtmuxなどの設定ファイルを反映させる
        link = {
          type = "app";
          program =
            let
              # home.nixから設定を読み込み
              homeConfig = import ./home-manager/home.nix {
                inherit inputs lib pkgs;
                config = { };
              };

              # home.fileの各エントリからリンクコマンドを生成
              linkCommands = lib.mapAttrsToList (
                target: config:
                let
                  targetPath = "$HOME/${target}";
                  sourcePath = toString config.source;
                  targetDir = builtins.dirOf targetPath;
                in
                ''
                  mkdir -p "${targetDir}"
                  ln -sf "${sourcePath}" "${targetPath}"
                  echo "Linked: ${sourcePath} -> ${targetPath}"
                ''
              ) homeConfig.home.file;
            in
            toString (
              pkgs.writeShellScript "link-script" ''
                set -e

                echo "Creating symlinks for config files..."
                ${lib.concatStringsSep "\n" linkCommands}
                echo "All symlinks created successfully!"
              ''
            );
        };
      };

      homeConfigurations = {
        home-manager.backupFileExtension = ".bak";
        myHomeConfig = home-manager.lib.homeManagerConfiguration {
          pkgs = pkgs;
          extraSpecialArgs = {
            inherit inputs;
          };
          modules = [
            ./home-manager/home.nix
          ];
        };
      };
    };
}
