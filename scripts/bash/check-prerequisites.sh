#!/usr/bin/env bash
# check-prerequisites.sh — Validates environment prerequisites for mema-kit git automation.
#
# Called by git automation scripts before running to ensure git, gh, and repo
# state are suitable. Also useful as a standalone diagnostic tool.
#
# USAGE:
#   check-prerequisites.sh [--need-gh] [--json]
#
# OPTIONS:
#   --need-gh   Also check that gh CLI is installed and authenticated
#   --json      Emit results as JSON; messages go to stdout
#
# MODES:
#   Flag mode    (--need-gh present): runs checks silently; exits 1 on first failure
#   Summary mode (no --need-gh):      prints pass/fail for all four checks; always exits 0
#
# OUTPUT — text mode, flag:
#   [silent on success]
#   [missing] Required tool not found: git
#   [error]   Not inside a git repository — run from your project root
#   [missing] Required tool not found: gh
#   [error]   gh CLI is not authenticated — run: gh auth login
#
# OUTPUT — text mode, summary:
#   [ok]      git is available
#   [ok]      inside a git repository
#   [ok]      gh CLI is available
#   [ok]      gh CLI is authenticated
#
# EXIT CODES:
#   0 — all checks passed (flag mode), or summary printed (summary mode)
#   1 — a required check failed (flag mode only)

# ---------------------------------------------------------------------------
# Self-locate and source shared library.
# ${BASH_SOURCE[0]} is more reliable than $0 when invoked via symlinks or
# called with an explicit path from a different working directory.
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
# common.sh activates: set -euo pipefail, git_root, output_result,
#                      check_prereq, parse_common_args

# ---------------------------------------------------------------------------
# Pass 1: parse common args.
# Sets OUTPUT_FORMAT=json if --json is present so all output_result calls
# below automatically emit JSON.
# ---------------------------------------------------------------------------
parse_common_args "$@"

# ---------------------------------------------------------------------------
# Pass 2: parse script-specific args.
# Detect --need-gh to know whether to run gh checks and which mode to use.
# ---------------------------------------------------------------------------
NEED_GH=0

for arg in "$@"; do
  case "$arg" in
    --need-gh) NEED_GH=1 ;;
    *)         ;;  # --json already handled; unknown flags silently ignored
  esac
done

# ---------------------------------------------------------------------------
# Mode selection.
# Summary mode  = NEED_GH is 0 (no operational flags; --json alone doesn't count)
#   → print pass/fail for all four checks; always exit 0
# Flag mode     = NEED_GH is 1
#   → run only the requested checks; silent on success; exit 1 on first failure
# ---------------------------------------------------------------------------

if [[ "$NEED_GH" -eq 0 ]]; then

  # -------------------------------------------------------------------------
  # SUMMARY MODE
  # Run every check independently (no exit on failure) and print a status
  # line for each. Useful for standalone debugging: bash check-prerequisites.sh
  # -------------------------------------------------------------------------

  # Check 1: git on PATH
  if command -v git &>/dev/null; then
    output_result "ok" "git is available"
  else
    output_result "missing" "git not found — install git to use mema-kit scripts" ', "check": "git"'
  fi

  # Check 2: inside a git repository
  if git rev-parse --show-toplevel &>/dev/null 2>&1; then
    output_result "ok" "inside a git repository"
  else
    output_result "error" "not inside a git repository — run from your project root" ', "check": "git-repo"'
  fi

  # Check 3: gh CLI on PATH
  if command -v gh &>/dev/null; then
    output_result "ok" "gh CLI is available"
  else
    output_result "missing" "gh CLI not found — install from https://cli.github.com" ', "check": "gh"'
  fi

  # Check 4: gh authenticated
  # Guard: only attempt auth check if gh is present — avoids "command not found"
  # noise when gh is not installed.
  if ! command -v gh &>/dev/null; then
    output_result "skipped" "gh CLI not installed — skipping auth check" ', "check": "gh-auth"'
  elif gh auth status &>/dev/null 2>&1; then
    output_result "ok" "gh CLI is authenticated"
  else
    output_result "error" "gh CLI is not authenticated — run: gh auth login" ', "check": "gh-auth"'
  fi

  exit 0

fi

# ---------------------------------------------------------------------------
# FLAG MODE
# Run only the checks appropriate for the requested flags.
# Silent on success; output_result + exit 1 on first failure.
# Callers use: check-prerequisites.sh --need-gh || exit 1
# ---------------------------------------------------------------------------

# Universal checks: git and repo state are always validated in flag mode.
check_prereq git || exit 1

if ! git rev-parse --show-toplevel &>/dev/null 2>&1; then
  output_result "error" "Not inside a git repository — run from your project root" ', "check": "git-repo"'
  exit 1
fi

# gh checks: only when --need-gh was passed (always true in flag mode currently,
# but kept explicit for future extensibility).
if [[ "$NEED_GH" -eq 1 ]]; then
  check_prereq gh || exit 1

  if ! gh auth status &>/dev/null 2>&1; then
    output_result "error" "gh CLI is not authenticated — run: gh auth login" ', "check": "gh-auth"'
    exit 1
  fi
fi

# All checks passed — exit silently.
exit 0
