{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        tofu = pkgs.writers.writeBashBin "tofu" ''
          set -a && source <(${pkgs.sops}/bin/sops --decrypt .env) && set +a
          test -d .terraform || ${pkgs.opentofu}/bin/tofu init -upgrade
          ${pkgs.opentofu}/bin/tofu "$@"
        '';
      in
      {
        apps = rec {
          default = plan;
          plan = {
            type = "app";
            program = toString (pkgs.writers.writeBash "plan" ''${tofu}/bin/tofu plan -out plan'');

          };
          apply = {
            type = "app";
            program = toString (pkgs.writers.writeBash "apply" ''${tofu}/bin/tofu apply -auto-approve
            '');

          };
          path = {
            type = "app";
            program = toString (pkgs.writers.writeBash "path" ''
              echo ${pkgs.opentofu}/bin/tofu
            '');
          };
        };
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              opentofu

              # Git and openssh are used by opentofu to fetch modules
              git
              openssh

              # Secrets management
              gnupg
              sops
              age
            ];

            shellHook = ''
              export HOME="$(echo ~)"
              set -a && source <(${pkgs.sops}/bin/sops --decrypt .env) && set +a
              test -d .terraform || ${pkgs.opentofu}/bin/tofu init -upgrade
            '';
          };
        };
      }
    );
}
