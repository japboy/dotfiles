{ pkgs }:

with pkgs;
[
  # Fundamental tools
  gh

  # Language runtimes and package managers
  mise

  # AI Agents
  claude-agent-acp
  claude-code
  codex
  codex-acp
  gemini-cli
  github-copilot-cli
]
