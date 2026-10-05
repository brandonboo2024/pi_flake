# Pi flake

Dedicated Nix flake for packaging the published npm release of
`@earendil-works/pi-coding-agent`.

## Outputs

- `packages.${system}.pi`
- `packages.${system}.default`
- `apps.${system}.pi`
- `apps.${system}.default`
- `overlays.default`

## Build and run

```sh
nix build .#pi
nix run .#pi -- --version
```

The package preserves upstream Pi behavior: the executable is `pi`, user config
stays under `~/.pi/agent`, and no provider keys or LiteLLM defaults are bundled.

## Updating

```sh
./update.sh 1.0.3
```

Without an argument, `update.sh` asks npm for the latest published version. The
script refreshes the npm tarball hash, npm dependency hash, and `flake.lock`.

Since Pi 1.0.1 the published npm tarball no longer ships a lockfile, so the
script also generates a `package-lock.json` from the tarball's `package.json`
and vendors it in this repo. That lockfile is what makes the dependency install
reproducible; commit it together with `package.nix` and `flake.lock`.

## Dotfiles integration

Add this flake as a dotfiles input, then add the package to Home Manager:

```nix
inputs.pi-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
```

Provider and model configuration should be managed separately in Home Manager,
for example as files under `~/.pi/agent/`.
