# Mike's Dotfiles

Super quick instructions on how this all works.

## Basics

- Clone the repository to your home directory.
- Create the required directories via `./create_dirs.sh`
- Set MacOS defaults via `./settings.sh`
- Configure the Dock via `./dock.sh`
- Install packages via `./install_pkgs.sh`
- Create symlinks using `./stow.sh`
- Install default programming languages and tools via `mise install`
  - `mise` is configured via `config/mise/config.toml`

## Package Management

- Packages are managed via the `packages.brewfile`
- Add a new file to the repo using `vi packages.brewfile`
- Run `./install_pkgs.sh` to install the package.
- Software languages and toolchains (except Rust which uses `rustup`) are configured via `mise`
