# Shared Nix code

This directory contains reusable Nix expressions shared by the repository
flakes under `darwin/` and `linux/`.

Subflakes import this directory as an explicit non-flake input:

```nix
inputs.commonNix = {
  url = "path:../common/nix";
  flake = false;
};
```

Evaluate subflakes from the repository root with the `dir` flake reference
parameter, for example:

```sh
nix flake check "path:$PWD?dir=linux"
nix flake check "path:$PWD?dir=darwin"
```

To refresh the package inputs, update both lock files from the repository root:

```sh
nix flake update nixpkgs-essentials nixpkgs-recent-version-packages --flake "path:$PWD?dir=darwin"
nix flake update nixpkgs-essentials nixpkgs-recent-version-packages --flake "path:$PWD?dir=linux"
```

Keep `nixpkgs-recent-version-packages` at the same revision in both lock files.
The shared MCP expressions and Darwin's Glance expression also pin upstream
versions and source hashes; updating the lock files does not update these pins.

The supported systems are `aarch64-darwin` and `x86_64-linux`. Validate each
package set with `nix flake check --no-build` and build its default package on
the corresponding system before updating a profile. For example, on Apple
Silicon:

```sh
nix flake check --no-build "path:$PWD?dir=darwin"
nix flake check --all-systems --no-build "path:$PWD?dir=linux"
nix build --no-link "path:$PWD?dir=darwin"
```

Using the repository root as the flake reference tree keeps
`../common/nix` inside the same flake tree. This is required for pure
evaluation when subflakes share sibling directories.

Shared files should be plain Nix functions that receive explicit dependencies,
for example `{ pkgs }: ...`, instead of defining their own flake outputs.
