#!/usr/bin/env bash
# create-feature-branch.sh — Creates a new git feature branch for the mema-kit per-feature cycle.
#
# Called by /mema.specify at the start of a new feature to create a consistently
# named local branch. Designed to be idempotent and safe to re-run.
#
# USAGE:
#   create-feature-branch.sh <NNN> <feature-name> [--short-name <name>] [--json]
#
# ARGUMENTS:
#   NNN           — Feature number (e.g. "002")
#   feature-name  — Kebab-case feature name (e.g. "create-feature-branch")
#
# OPTIONS:
#   --short-name <name>  Override the branch name suffix (default: feature-name arg)
#   --json               Emit result as JSON to stdout; all other messages go to stderr
#
# OUTPUT — text mode:
#   [created] Branch created: feat-002-create-feature-branch
#   [exists]  Branch already exists: feat-002-create-feature-branch
#   [error]   Working directory is dirty — commit or stash changes before creating a branch
#
# OUTPUT — json mode:
#   {"status": "created", "message": "...", "branch": "feat-002-name", "base": "main"}
#   {"status": "exists",  "message": "...", "branch": "feat-002-name", "base": "main"}
#   {"status": "error",   "message": "..."}
#
# EXIT CODES:
#   0 — branch created or already existed (idempotent success)
#   1 — dirty working directory, missing args, missing git, or unexpected error

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
# Pass 1: Parse common args.
# parse_common_args uses a for-loop and does NOT consume "$@", so the full
# argument list is still available for our own parsing pass below.
# Sets OUTPUT_FORMAT=json if --json is present.
# ---------------------------------------------------------------------------
parse_common_args "$@"

# Verify git is available before doing anything else.
check_prereq git || exit 1

# ---------------------------------------------------------------------------
# Pass 2: Parse script-specific args.
# Extracts positional args and --short-name. --json is re-encountered here
# and skipped — it was already handled by parse_common_args above.
# ---------------------------------------------------------------------------
feature_num=""
feature_name=""
short_name_override=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      # Already handled by parse_common_args; skip.
      shift
      ;;
    --short-name)
      # Guard against --short-name with no following value.
      if [[ $# -lt 2 ]]; then
        echo "Error: --short-name requires a value" >&2
        exit 1
      fi
      short_name_override="$2"
      shift 2
      ;;
    -*)
      # Unknown flag — silently ignore to stay forward-compatible.
      shift
      ;;
    *)
      # Positional argument: first is NNN, second is feature-name.
      if [[ -z "$feature_num" ]]; then
        feature_num="$1"
      elif [[ -z "$feature_name" ]]; then
        feature_name="$1"
      fi
      shift
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Input validation.
# Both a feature number and a branch name suffix are required. The suffix
# comes from either <feature-name> or --short-name.
# ---------------------------------------------------------------------------
if [[ -z "$feature_num" ]]; then
  echo "Error: missing required argument <NNN> (feature number, e.g. 002)" >&2
  echo "Usage: create-feature-branch.sh <NNN> <feature-name> [--short-name <name>] [--json]" >&2
  exit 1
fi

if [[ -z "$feature_name" && -z "$short_name_override" ]]; then
  echo "Error: missing required argument <feature-name> (or use --short-name <name>)" >&2
  echo "Usage: create-feature-branch.sh <NNN> <feature-name> [--short-name <name>] [--json]" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Capture base branch and construct target branch name.
# base_branch is captured BEFORE any git operations so the output correctly
# records the branch we diverged from, even after we switch branches.
# ---------------------------------------------------------------------------
base_branch="$(git rev-parse --abbrev-ref HEAD)"

# Use --short-name override if provided; fall back to the feature-name positional arg.
branch_name="feat-${feature_num}-${short_name_override:-${feature_name}}"

# ---------------------------------------------------------------------------
# Dirty-dir guard.
# git status --porcelain is intentionally conservative: it reports untracked
# files (??), staged changes, and unstaged changes. Any output means the
# working directory is not clean enough for a safe branch creation.
# The dirty file list always goes to stderr so it never taints JSON stdout.
# ---------------------------------------------------------------------------
dirty="$(git status --porcelain)"
if [[ -n "$dirty" ]]; then
  echo "Dirty files:" >&2
  echo "$dirty" >&2
  output_result "error" "Working directory is dirty — commit or stash changes before creating a branch"
  exit 1
fi

# ---------------------------------------------------------------------------
# Idempotency check.
# git branch --list "name" emits the branch name (with leading whitespace)
# if it exists locally, or empty output if it does not. grep -q . tests for
# any non-empty output (the dot matches any character, so any output passes).
# If the branch exists: checkout (no-op if already on it; git returns 0) and exit 0.
# ---------------------------------------------------------------------------
if git branch --list "${branch_name}" | grep -q .; then
  git checkout "${branch_name}"
  output_result "exists" \
    "Branch already exists: ${branch_name}" \
    ", \"branch\": \"${branch_name}\", \"base\": \"${base_branch}\""
  exit 0
fi

# ---------------------------------------------------------------------------
# Branch creation.
# git checkout -b creates the branch and switches to it in one atomic step.
# set -euo pipefail (inherited from common.sh) ensures any failure exits
# immediately with a non-zero code rather than silently continuing.
# ---------------------------------------------------------------------------
git checkout -b "${branch_name}"

output_result "created" \
  "Branch created: ${branch_name}" \
  ", \"branch\": \"${branch_name}\", \"base\": \"${base_branch}\""
