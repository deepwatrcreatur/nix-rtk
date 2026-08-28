{
  description = "RTK hook integration for AI coding agents - companion to numtide/llm-agents.nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, llm-agents }:
  let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in
  {
    # Re-export llm-agents overlay for convenience
    overlays.default = llm-agents.overlays.shared-nixpkgs or llm-agents.overlays.default;

    # Home-manager module for RTK hook integration
    homeManagerModules = {
      default = self.homeManagerModules.rtk-hooks;
      rtk-hooks = import ./modules/rtk-hooks.nix;
    };

    # Packages re-exported from llm-agents for convenience
    packages = forAllSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (llm-agents.overlays.shared-nixpkgs or llm-agents.overlays.default) ];
          config.allowUnfree = true;
        };
      in {
        inherit (pkgs.llm-agents) rtk claude-code opencode codex gemini-cli;
        default = pkgs.llm-agents.rtk;
      }
    );
  };
}
