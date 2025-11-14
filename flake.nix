{
  description = "Python development template with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Configure Python version here (e.g., "39", "310", "311", "312", "313")
        pythonVersion = "311";
        
        pythonPackages = pkgs."python${pythonVersion}Packages";
        
        pythonEnv = pythonPackages.python.withPackages (ps: with ps; [
          pytest
          pytest-cov
          ruff
        ]);
        
        # Production Python environment (without dev dependencies)
        pythonEnvProd = pythonPackages.python.withPackages (ps: with ps; [
          # Add your production dependencies here
          # For example: fastapi, uvicorn, requests, etc.
        ]);

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            pythonEnv
            pythonPackages.pip
            pythonPackages.setuptools
            pythonPackages.wheel
          ];

          shellHook = ''
            echo "Python development environment"
            echo "Available commands:"
            echo "  nix run .#test   - Run tests with pytest"
            echo "  nix run .#lint   - Check code with ruff"
            echo "  nix run .#format - Format code with ruff"
            echo ""
            echo "Python version: $(python --version)"
          '';
        };

        apps = {
          test = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "test" ''
              set -e
              echo "Running tests with pytest..."
              ${pythonEnv}/bin/pytest tests/ -v --cov=src --cov-report=term-missing
            ''}/bin/test";
          };

          lint = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "lint" ''
              set -e
              echo "Checking code with ruff..."
              ${pythonEnv}/bin/ruff check src/ tests/
            ''}/bin/lint";
          };

          format = {
            type = "app";
            program = "${pkgs.writeShellScriptBin "format" ''
              set -e
              echo "Formatting code with ruff..."
              ${pythonEnv}/bin/ruff format src/ tests/
              echo "Fixing lint issues..."
              ${pythonEnv}/bin/ruff check --fix src/ tests/
            ''}/bin/format";
          };
        };

        packages = {
          default = pythonPackages.buildPythonPackage {
            pname = "example-package";
            version = "0.1.0";
            src = ./.;
            
            propagatedBuildInputs = with pythonPackages; [
            ];

            checkInputs = with pythonPackages; [
              pytest
              pytest-cov
              ruff
            ];

            checkPhase = ''
              pytest tests/
            '';
          };

          dockerImage = pkgs.dockerTools.buildImage {
            name = "python-app";
            tag = "latest";
            
            copyToRoot = pkgs.buildEnv {
              name = "image-root";
              paths = [
                pythonEnvProd
                # Copy your application code
                (pkgs.runCommand "app-source" {} ''
                  mkdir -p $out/app
                  cp -r ${./src}/* $out/app/
                '')
                # Add a simple entrypoint script
                (pkgs.writeScriptBin "entrypoint" ''
                  #!${pkgs.bash}/bin/bash
                  cd /app
                  export PYTHONPATH=/app:$PYTHONPATH
                  exec ${pythonEnvProd}/bin/python -m example.main "$@"
                '')
              ];
              pathsToLink = [ "/bin" "/app" ];
            };

            config = {
              Cmd = [ "/bin/entrypoint" ];
              WorkingDir = "/app";
              Env = [
                "PYTHONUNBUFFERED=1"
                "PYTHONDONTWRITEBYTECODE=1"
              ];
              ExposedPorts = {
                # Add your ports here if needed
                # "8000/tcp" = {};
              };
              Labels = {
                "org.opencontainers.image.description" = "Python application built with Nix";
                "org.opencontainers.image.source" = "https://github.com/yourusername/your-repo";
              };
            };
          };
        };
      });
}