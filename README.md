# nix-rtk

Home-manager module for RTK hook integration with AI coding agents.

**Companion to [numtide/llm-agents.nix](https://github.com/numtide/llm-agents.nix)** - this flake provides declarative hook management, while llm-agents.nix provides the packages.

## What is RTK?

[RTK (Rust Token Killer)](https://github.com/rtk-ai/rtk) is a CLI proxy that reduces LLM token consumption by 60-90% on common dev commands. It intercepts shell commands and returns optimized, token-efficient output.

## Features

- **Declarative hook management** - Enable/disable RTK hooks via home-manager options
- **Idempotent activation** - Only reinstalls hooks when configuration changes
- **Supported integrations**:
  - Claude Code (`--global --auto-patch`)
  - OpenAI Codex (`--global --codex`)
  - Google Gemini CLI (`--global --gemini --auto-patch`)
  - OpenCode (`--global --opencode`)

## Usage

### Add to flake inputs

```nix
{
  inputs = {
    nix-rtk.url = "github:deepwatrcreatur/nix-rtk";
    # llm-agents is included transitively, but you can pin it:
    # nix-rtk.inputs.llm-agents.follows = "llm-agents";
  };
}
```

### Home-manager configuration

```nix
{ inputs, ... }:
{
  imports = [ inputs.nix-rtk.homeManagerModules.default ];

  programs.rtk-hooks = {
    enable = true;
    integrations = {
      claude.enable = true;   # Enable RTK hooks for Claude Code
      codex.enable = false;   # Disable for Codex
      gemini.enable = false;  # Disable for Gemini
      opencode.enable = true; # Enable for OpenCode
    };
  };
}
```

### Using the overlay

This flake re-exports the `llm-agents` overlay for convenience:

```nix
{
  nixpkgs.overlays = [ inputs.nix-rtk.overlays.default ];

  # Then use packages:
  home.packages = with pkgs.llm-agents; [
    rtk
    claude-code
    opencode
    codex
    gemini-cli
  ];
}
```

## Packages

For convenience, key packages are re-exported from llm-agents.nix:

```bash
nix run github:deepwatrcreatur/nix-rtk#rtk -- --help
nix run github:deepwatrcreatur/nix-rtk#claude-code -- --help
nix run github:deepwatrcreatur/nix-rtk#opencode -- --help
```

For the full package list (60+ AI coding agents), see [numtide/llm-agents.nix](https://github.com/numtide/llm-agents.nix).

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Your Flake                           │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────────────────┐ │
│  │   nix-rtk       │    │  numtide/llm-agents.nix     │ │
│  │  (this flake)   │───▶│  (packages: rtk, claude,    │ │
│  │                 │    │   codex, opencode, etc.)    │ │
│  │  Home-manager   │    │                             │ │
│  │  module for     │    │  60+ AI coding agents       │ │
│  │  RTK hooks      │    │  Updated daily              │ │
│  └─────────────────┘    └─────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## Why not contribute upstream?

This module could potentially be contributed to llm-agents.nix. However:
1. It requires home-manager as a dependency (llm-agents.nix is pure packages)
2. The RTK hook workflow is opinionated
3. Keeping it separate allows faster iteration

## License

MIT
