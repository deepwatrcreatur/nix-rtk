# RTK hook integration for AI coding agents
# Manages installation/uninstallation of RTK hooks for supported CLI tools
{ config, lib, pkgs, ... }:

let
  cfg = config.programs.rtk-hooks;

  # RTK integration flags for each supported agent
  integrations = {
    claude = {
      description = "Claude Code";
      flags = [ "--global" "--auto-patch" ];
    };
    codex = {
      description = "OpenAI Codex";
      flags = [ "--global" "--codex" ];
    };
    gemini = {
      description = "Google Gemini CLI";
      flags = [ "--global" "--gemini" "--auto-patch" ];
    };
    opencode = {
      description = "OpenCode";
      flags = [ "--global" "--opencode" ];
    };
  };

  enabledIntegrations = lib.filterAttrs (_: v: v.enable) cfg.integrations;
  enabledNames = lib.attrNames enabledIntegrations;

  # State tracking for idempotent hook management
  desiredState = builtins.toJSON {
    version = 1;
    enabled = enabledNames;
  };

  shellArgs = args: lib.concatStringsSep " " (map lib.escapeShellArg args);

  # Use RTK from llm-agents overlay or fall back to pkgs
  rtk = pkgs.llm-agents.rtk or pkgs.rtk or (throw "RTK not found - ensure llm-agents overlay is applied");
in
{
  options.programs.rtk-hooks = {
    enable = lib.mkEnableOption "RTK hook management for AI coding agents";

    integrations = lib.mapAttrs (name: meta: {
      enable = lib.mkEnableOption "RTK hook for ${meta.description}";
    }) integrations;
  };

  config = lib.mkIf cfg.enable {
    # Ensure RTK is available
    home.packages = [ rtk ];

    # Manage hook installation/uninstallation
    home.activation.rtkHooks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      state_dir="${config.xdg.stateHome}/rtk-hooks"
      state_file="$state_dir/state.json"
      desired_state=${lib.escapeShellArg desiredState}
      previous_state=""

      if [ -f "$state_file" ]; then
        previous_state="$(cat "$state_file")"
      fi

      if [ "$previous_state" != "$desired_state" ]; then
        mkdir -p "$state_dir"

        # Uninstall hooks that were previously enabled
        ${lib.concatMapStringsSep "\n" (name: ''
          case "$previous_state" in
            *'"${name}"'*)
              ${lib.getExe rtk} init ${shellArgs (integrations.${name}.flags ++ [ "--uninstall" ])} 2>/dev/null || true
              ;;
          esac
        '') (lib.attrNames integrations)}

        # Install currently enabled hooks
        ${lib.concatMapStringsSep "\n" (name: ''
          ${lib.getExe rtk} init ${shellArgs integrations.${name}.flags}
        '') enabledNames}

        printf '%s' "$desired_state" > "$state_file"
      fi
    '';
  };
}
