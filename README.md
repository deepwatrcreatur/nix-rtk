# nix-rtk

Nix flake packaging for [`rtk-ai/rtk`](https://github.com/rtk-ai/rtk).

## Usage

```nix
{
  inputs.nix-rtk.url = "github:deepwatrcreatur/nix-rtk";

  outputs = { self, nixpkgs, nix-rtk, ... }: {
    homeConfigurations.me = ... {
      home.packages = [
        nix-rtk.packages.x86_64-linux.default
      ];
    };
  };
}
```

## Status

This flake currently packages the upstream `rtk` CLI binary. Hook and config
integration for Claude Code, Codex, OpenCode, and Gemini can be layered on top
in downstream configs.
