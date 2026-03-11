#!/usr/bin/env bash
# create-pr.sh — Creates a draft GitHub pull request for the current feature branch.
#
# Called by /mema.implement after all tasks are complete and the branch has been
# committed and pushed via commit-changes.sh. Designed to be idempotent and safe
# to re-run: if a PR already exists for the current branch, the script exits 0
# without creating a duplicate.
#
# Degrades gracefully when gh is not installed or the remote is not GitHub — prints
# manual steps to stderr and exits 0 rather than failing hard.
#
# USAGE:
#   create-pr.sh [--json] [--base <branch>] <title> [body]
#
# ARGUMENTS:
#   title  — PR title (required); Claude supplies this
#   body   — PR body/description (optional); defaults to empty string
#
# OPTIONS:
#   --base <branch>  Base branch for the PR (default: main)
#   --json           Emit result as JSON to stdout; all other messages go to stderr
#
# OUTPUT — text mode:
#   [created] PR opened (draft): https://github.com/owner/repo/pull/42
#   [exists]  PR already open: https://github.com/owner/repo/pull/42
#   [missing] gh not installed — see manual steps above
#   [skipped] Non-GitHub remote — PR creation skipped
#   [error]   Branch 'feat-004-create-pr' has no remote tracking ref. Push first.
#
# OUTPUT — json mode:
#   {"status": "created", "message": "...", "created": true,  "url": "...", "branch": "...", "draft": true}
#   {"status": "exists",  "message": "...", "created": false, "url": "...", "branch": "...", "draft": true}
#   {"status": "missing", "message": "...", "created": false, "branch": "..."}
#   {"status": "skipped", "message": "...", "created": false, "branch": "...", "manual_url": "..."}
#   {"status": "error",   "message": "..."}
#
# EXIT CODES:
#   0 — PR created, PR already exists, gh missing (graceful), or non-GitHub remote (graceful)
#   1 — branch not pushed, missing title, git not found, or unexpected error

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
# Extracts positional args (title, body) and --base. --json is re-encountered
# here and skipped — it was already handled by parse_common_args above.
# ---------------------------------------------------------------------------
title=""
body=""
base_branch="main"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      # Already handled by parse_common_args; skip.
      shift
      ;;
    --base)
      # Guard against --base with no following value.
      if [[ $# -lt 2 ]]; then
        echo "Error: --base requires a value" >&2
        exit 1
      fi
      base_branch="$2"
      shift 2
      ;;
    -*)
      # Unknown flag — silently ignore to stay forward-compatible.
      shift
      ;;
    *)
      # Positional argument: first is title, second is body.
      if [[ -z "$title" ]]; then
        title="$1"
      elif [[ -z "$body" ]]; then
        body="$1"
      fi
      shift
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Input validation: require a non-empty PR title.
# ---------------------------------------------------------------------------
if [[ -z "$title" ]]; then
  echo "Error: missing required argument <title>" >&2
  echo "Usage: create-pr.sh [--json] [--base <branch>] <title> [body]" >&2
  echo "Example: create-pr.sh \"feat(cli): add --json flag\" \"Adds --json output mode\"" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Capture current branch. Done here (before any conditional exits) so it is
# available in all output paths below.
# ---------------------------------------------------------------------------
current_branch="$(git rev-parse --abbrev-ref HEAD)"

# ---------------------------------------------------------------------------
# gh availability check — graceful degradation.
# Unlike check_prereq (which exits 1 on failure), we exit 0 here because a
# missing gh CLI is not an error — the user can create the PR manually.
# Manual instructions always go to stderr; the machine result goes to stdout.
# ---------------------------------------------------------------------------
if ! command -v gh &>/dev/null; then
  echo "gh CLI not found. To create a PR manually:" >&2
  echo "  1. Ensure your branch is pushed: git push -u origin ${current_branch}" >&2
  echo "  2. Open a PR at: https://github.com/<owner>/<repo>/compare/${current_branch}" >&2
  output_result "missing" "gh not installed — see manual steps above" \
    ", \"created\": false, \"branch\": \"${current_branch}\""
  exit 0
fi

# ---------------------------------------------------------------------------
# Remote URL check — non-GitHub detection.
# gh pr create only works with GitHub-hosted repos. If the origin remote is
# GitLab, Bitbucket, or anything else, degrade gracefully instead of failing.
# The || true prevents set -e from killing the script if origin doesn't exist.
# ---------------------------------------------------------------------------
remote_url="$(git remote get-url origin 2>/dev/null || true)"
if [[ "$remote_url" != *github.com* ]]; then
  echo "Remote is not GitHub (${remote_url:-no origin remote found})." >&2
  echo "To create a PR manually, visit your hosting provider and open a PR for: ${current_branch}" >&2
  output_result "skipped" "Non-GitHub remote — PR creation skipped" \
    ", \"created\": false, \"branch\": \"${current_branch}\", \"manual_url\": \"${remote_url:-}\""
  exit 0
fi

# ---------------------------------------------------------------------------
# Branch-pushed check — hard error (exit 1).
# If the branch has no remote tracking ref, there is nothing gh can PR against.
# This is a real error state, not a graceful-degradation case — the user must
# push the branch first (commit-changes.sh handles this automatically).
# ---------------------------------------------------------------------------
if ! git rev-parse --abbrev-ref --symbolic-full-name "@{u}" &>/dev/null; then
  output_result "error" \
    "Branch '${current_branch}' has no remote tracking ref. Push the branch first (commit-changes.sh handles this)."
  exit 1
fi

# ---------------------------------------------------------------------------
# Idempotency check — detect existing open PR before creating.
# gh pr list --json url --jq '.[0].url' extracts the URL of the first result.
# The || true prevents set -e from aborting if gh returns non-zero (e.g. no
# open PRs found for this branch returns an empty list, not an error, but
# older gh versions may exit non-zero in edge cases).
# ---------------------------------------------------------------------------
existing_url="$(gh pr list --head "${current_branch}" --state open --json url --jq '.[0].url' 2>/dev/null || true)"
if [[ -n "$existing_url" ]]; then
  output_result "exists" "PR already open: ${existing_url}" \
    ", \"created\": false, \"url\": \"${existing_url}\", \"branch\": \"${current_branch}\", \"draft\": true"
  exit 0
fi

# ---------------------------------------------------------------------------
# Create the draft PR.
# gh pr create prints the new PR URL to stdout; we capture it directly.
# Diagnostic progress messages from gh go to stderr automatically.
# set -euo pipefail (inherited from common.sh) ensures any failure here exits
# immediately rather than silently continuing with an empty pr_url.
# ---------------------------------------------------------------------------
pr_url="$(gh pr create --draft --title "${title}" --body "${body:-}" --base "${base_branch}")"

output_result "created" "PR opened (draft): ${pr_url}" \
  ", \"created\": true, \"url\": \"${pr_url}\", \"branch\": \"${current_branch}\", \"draft\": true"
