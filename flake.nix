{
  description = "A simple command line tool for sending and receiving Open Sound Control (OSC) commands";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      # We added 'system' to the arguments passed to f
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
        inherit system;
      });
    in
    {
      packages = forEachSupportedSystem ({ pkgs, ... }: {
        default = pkgs.buildGoModule {
          pname = "osc-utility";
          version = "0.3.0";

          src = ./.;
          vendorHash = "sha256-tifqI9K6hSkq26/LJalFqN+xyPmvRJRlf20NVxzM5Wo=";

          meta = with pkgs.lib; {
            description = "A simple command line tool for sending and receiving OSC commands";
            homepage = "https://github.com/72nd/osc-utility";
            license = licenses.mit;
            platforms = platforms.all;
            maintainers = [ ];
          };
        };
      });

      # Allows you to run it directly with `nix run`
      apps = forEachSupportedSystem ({ system, ... }: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/osc-utility";
        };
      });

      # Creates an overlay for your system flake
      overlays.default = final: prev: {
        osc-utility = self.packages.${prev.system}.default;
      };

      devShells = forEachSupportedSystem ({ pkgs, ... }: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            gotools
          ];
        };
      });
    };
}
