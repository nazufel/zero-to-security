#!/usr/bin/env bash
# block-risky.sh: a Claude Code PreToolUse hook that blocks risky shell commands.
# Claude Code sends the tool call as JSON on stdin. Exit 2 blocks it, and
# whatever this script prints to stderr is shown to Claude as the reason.

command=$(jq -r '.tool_input.command // ""')

block() {
  echo "Blocked by policy: $1" >&2
  exit 2
}

case "$command" in
  *"curl "*"| sh"* | *"curl "*"| bash"* | *"wget "*"| sh"* | *"wget "*"| bash"*)
    block "piping a download into a shell runs code nobody has read" ;;
  *"rm -rf /"* | *"rm -rf ~"* | *'rm -rf $HOME'*)
    block "recursive delete of / or a home directory" ;;
  *"git push --force"* | *"git push -f"*)
    block "force-pushing rewrites shared history" ;;
  *"chmod 777"* | *"chmod -R 777"*)
    block "chmod 777 gives everyone full access (Module 2, lesson 4)" ;;
  *".tfstate"*)
    block "state files can contain secrets (Module 6, lesson 3)" ;;
esac

exit 0
