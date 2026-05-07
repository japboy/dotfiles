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

Using the repository root as the flake reference tree keeps
`../common/nix` inside the same flake tree. This is required for pure
evaluation when subflakes share sibling directories.

Shared files should be plain Nix functions that receive explicit dependencies,
for example `{ pkgs }: ...`, instead of defining their own flake outputs.
