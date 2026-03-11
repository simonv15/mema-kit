#!/usr/bin/env bash
# common.sh — Shared bash library for mema-kit git automation scripts.
#
# USAGE (from any git automation script in scripts/bash/):
#   SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#   source "${SCRIPT_DIR}/common.sh"
#
# After sourcing, call parse_common_args "$@" to handle the --json flag,
# then use git_root, output_result, and check_prereq as needed.

# ---------------------------------------------------------------------------
# Double-source guard — safe to source multiple times.
#
# Uses ${COMMON_SH_LOADED:-} instead of $COMMON_SH_LOADED to avoid an
# "unbound variable" error from set -u on the first source, before COMMON_SH_LOADED
# has been defined.
# ---------------------------------------------------------------------------
[[ -n "${COMMON_SH_LOADED:-}" ]] && return 0
COMMON_SH_LOADED=1

# Strict mode: exit on any error (-e), treat unbound variables as errors (-u),
# and propagate pipe failures (-o pipefail). Scripts that source this file
# inherit these settings automatically.
set -euo pipefail

# ---------------------------------------------------------------------------
# git_root
#
# Prints the absolute path of the current git repository root to stdout.
# Exits non-zero with an error message to stderr if not inside a git repo.
#
# Example:
#   root="$(git_root)" || exit 1
#   cd "$root"
# ---------------------------------------------------------------------------
git_root() {
  # 2>/dev/null suppresses git's own "not a git repository" error message
  # so we can emit a consistent error instead.
  git rev-parse --show-toplevel 2>/dev/null || {
    echo "Error: not inside a git repository" >&2
    return 1
  }
}

# ---------------------------------------------------------------------------
# output_result <status> <message> [extra_json]
#
# Prints a result in JSON or plain-text format depending on OUTPUT_FORMAT.
#
# Arguments:
#   status     — short status string (e.g. "ok", "error", "missing")
#   message    — human-readable description
#   extra_json — optional; pre-formatted JSON fragment starting with ", "
#                e.g. ', "tool": "gh"'  is appended inside the JSON object
#
# Output format is controlled by OUTPUT_FORMAT (default: text):
#   text → [status] message
#   json → {"status": "…", "message": "…"[, extra_json fields]}
#
# Set OUTPUT_FORMAT=json by calling parse_common_args "$@" at the top of
# each script, or by setting it directly before calling output_result.
#
# Examples:
#   output_result "ok" "Branch created: 001-my-feature"
#   output_result "missing" "Tool not found: gh" ', "tool": "gh"'
# ---------------------------------------------------------------------------
output_result() {
  local status="$1"
  local message="$2"
  local extra="${3:-}"  # optional extra JSON fragment, e.g. ', "branch": "001-foo"'

  if [[ "${OUTPUT_FORMAT:-text}" == "json" ]]; then
    echo "{\"status\": \"${status}\", \"message\": \"${message}\"${extra}}"
  else
    echo "[${status}] ${message}"
  fi
}

# ---------------------------------------------------------------------------
# check_prereq <tool>
#
# Checks that <tool> is available on $PATH.
# Returns 0 if found; calls output_result and returns 1 if missing.
#
# Example:
#   check_prereq git || exit 1
#   check_prereq gh  || exit 1   # non-fatal: caller may choose to degrade
# ---------------------------------------------------------------------------
check_prereq() {
  local tool="$1"

  if ! command -v "$tool" &>/dev/null; then
    # ', "tool": "gh"' extends the JSON object so callers can read the tool name
    output_result "missing" "Required tool not found: ${tool}" ", \"tool\": \"${tool}\""
    return 1
  fi
}

# ---------------------------------------------------------------------------
# parse_common_args "$@"
#
# Parses arguments shared across all git automation scripts.
# Currently handles:
#   --json   sets OUTPUT_FORMAT=json so output_result emits JSON
#
# NOTE: Call this at the top of each script, before using output_result,
# so that the output format is set correctly for all subsequent calls.
# Unknown flags are silently ignored — scripts can extend this with their
# own argument parsing after calling parse_common_args.
#
# Example:
#   parse_common_args "$@"
#   # OUTPUT_FORMAT is now set; proceed to parse script-specific args
# ---------------------------------------------------------------------------
parse_common_args() {
  for arg in "$@"; do
    case "$arg" in
      --json) OUTPUT_FORMAT=json ;;
      *)      ;;  # ignore unknown flags
    esac
  done
}
