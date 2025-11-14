# Python with Nix Template

[![CI](https://github.com/yourusername/your-repo-name/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/your-repo-name/actions/workflows/ci.yml)

A GitHub template repository for Python projects using Nix flakes. This template provides a reproducible development environment with common Python development tools pre-configured.

## Features

- 🐍 Python environment managed by Nix
- 🧪 Testing with pytest and coverage reporting
- 🎨 Code formatting and linting with ruff
- ❄️ Fully reproducible development environment
- 📦 No need for virtualenv or pip - everything is managed by Nix
- 🐳 Docker image building without Docker daemon
- 🚀 Production-ready container images with minimal size

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- Git

### Enable Nix Flakes

If you haven't enabled flakes yet, add this to `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`:

```
experimental-features = nix-command flakes
```

## Quick Start

### Using as a GitHub Template

1. Click the "Use this template" button on GitHub
2. Clone your new repository:
   ```bash
   git clone https://github.com/yourusername/your-repo-name.git
   cd your-repo-name
   ```

### Setting Up the Development Environment

Enter the development shell:

```bash
nix develop
```

This will provide you with:
- Python 3.11
- pytest for testing
- ruff for linting and formatting
- All other dependencies defined in the flake

## Available Commands

The template provides several Nix apps for development and deployment:

### Development Commands

#### Run Tests
```bash
nix run .#test
```
Runs pytest with coverage reporting.

#### Lint Code
```bash
nix run .#lint
```
Checks code quality using ruff.

#### Format Code
```bash
nix run .#format
```
Formats code and fixes common issues using ruff.

### Docker Container Building

#### Build Docker Image
```bash
# Build the standard Docker image
nix build .#dockerImage

# Load the image into Docker
docker load < result

# Run the container
docker run python-app:latest
```

## Project Structure

```
.
├── flake.nix           # Nix flake configuration
├── flake.lock          # Locked dependencies (auto-generated)
├── pyproject.toml      # Python project configuration
├── README.md           # This file
├── .gitignore          # Git ignore patterns
├── src/
│   └── example/        # Your Python package
│       ├── __init__.py
│       └── main.py     # Example module
└── tests/
    ├── __init__.py
    └── test_example.py # Example tests
```

## Customization

### Modifying the Python Package

1. Rename the `src/example/` directory to your package name
2. Update the package name in `pyproject.toml`
3. Update the import in `tests/test_example.py`

### Changing Python Version

To use a different Python version, edit the `pythonVersion` variable in `flake.nix` (line 15):

```nix
# Configure Python version here (e.g., "39", "310", "311", "312", "313")
pythonVersion = "312";  # Change to your desired version
```

Available versions depend on your nixpkgs channel but typically include:
- `"39"` for Python 3.9
- `"310"` for Python 3.10
- `"311"` for Python 3.11 (default)
- `"312"` for Python 3.12
- `"313"` for Python 3.13

### Adding Dependencies

To add Python dependencies, edit `flake.nix`:

#### Development Dependencies
```nix
pythonEnv = pythonPackages.python.withPackages (ps: with ps; [
  pytest
  pytest-cov
  ruff
  # Add your dev dependencies here
]);
```

#### Production Dependencies
```nix
pythonEnvProd = pythonPackages.python.withPackages (ps: with ps; [
  # Add your production dependencies here
  # For example: fastapi, uvicorn, requests, etc.
]);
```

Then run `nix develop` to reload the environment.

### Docker Deployment

#### Configuring the Docker Image

Edit `flake.nix` to customize your Docker image:

1. **Add production dependencies** to `pythonEnvProd`
2. **Configure exposed ports** in the `ExposedPorts` section
3. **Modify the entrypoint** if needed for your application
4. **Add environment variables** in the `Env` section

#### Building for Production

```bash
# Build the Docker image
nix build .#dockerImage

# The image will be in ./result
# Load it into Docker
docker load < result

# Tag it for your registry
docker tag python-app:latest your-registry/your-app:version

# Push to registry
docker push your-registry/your-app:version
```

#### Multi-Architecture Builds

For multi-arch Docker images (arm64, amd64), you can:
```bash
# Build for specific architecture
nix build .#dockerImage --system aarch64-linux
nix build .#dockerImage --system x86_64-linux
```

### Configuring Tools

#### Ruff Configuration
Edit the `[tool.ruff]` section in `pyproject.toml` to customize linting and formatting rules.

#### Pytest Configuration
Edit the `[tool.pytest.ini_options]` section in `pyproject.toml` to configure test discovery and execution.

## CI/CD Integration

### GitHub Actions

This template includes a complete GitHub Actions workflow (`.github/workflows/ci.yml`) that automatically:

- **Runs on**: Push to main/master branches and pull requests
- **Tests on**: Ubuntu and macOS
- **Executes**: Linting, testing, formatting checks, and Docker image building
- **Uses**: Cachix for faster builds
- **Produces**: Docker images as downloadable artifacts

The workflow runs three main jobs:
1. **Lint and Test**: Runs `nix run .#lint` and `nix run .#test` on multiple OS
2. **Format Check**: Verifies code formatting is correct
3. **Build Docker**: Builds Docker image

### Docker Images in CI

The CI workflow automatically:
- **Builds Docker image** after tests pass
- **Uploads artifacts** that can be downloaded from the Actions tab
- **Shows image sizes** in the workflow summary
- **Retains artifacts** for 7 days
- **Releases assets** when you create a GitHub release (tag-based)

#### Downloading Docker Images from CI

1. Go to the **Actions** tab in your GitHub repository
2. Click on a successful workflow run
3. Scroll to **Artifacts** section
4. Download `docker-image` artifact
5. Extract and load the image:
   ```bash
   tar -xzf docker-images.zip
   docker load < docker-image.tar.gz
   ```

#### Automatic Release Uploads

When you create a GitHub release with a tag, the Docker image are automatically attached as release assets:
```bash
git tag v1.0.0
git push origin v1.0.0
# Create release on GitHub → Docker image auto-attached
```

#### Customizing the Workflow

To modify the workflow, edit `.github/workflows/ci.yml`. For example:
- Push image to Docker Hub or GitHub Container Registry
- Add multi-architecture builds
- Integrate with Kubernetes deployments
- Add security scanning with Trivy or Snyk

## Tips and Tricks

### Running Python Scripts

While in the development shell (`nix develop`), you can run Python scripts normally:

```bash
python src/example/main.py
```

### Installing Additional Tools

The development shell includes pip, so you can temporarily install packages for experimentation:

```bash
pip install some-package  # Only available in current shell session
```

For permanent additions, add them to `flake.nix`.

### Building a Python Package

The flake includes a default package definition:

```bash
nix build
```

This creates a Python package that can be distributed or installed.

## Troubleshooting

### Flake Not Found
Ensure you're in the repository root and that flakes are enabled in your Nix configuration.

### Python Import Errors
The `pythonpath` is configured in `pyproject.toml` to include the `src` directory. Make sure your imports match your package structure.

### Tool Versions
All tool versions are pinned through the Nix flake, ensuring consistency across different machines.

## Contributing

This is a template repository meant to be a starting point for Python projects. Feel free to:
1. Fork and customize for your needs
2. Submit issues for bugs or suggestions
3. Share your improvements with the community

## License

This template is provided as-is for use in your own projects. Add your preferred license for your actual project.

## Resources

- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)
- [Python Packaging Guide](https://packaging.python.org/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Pytest Documentation](https://docs.pytest.org/)