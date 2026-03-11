#!/usr/bin/env bash
# commit-changes.sh — Validates a Conventional Commits message, shows the staged
#                      diff, runs git commit, and pushes to the current branch.
#
# Called by /mema.implement at the end of the per-feature cycle, after all tasks
# are complete and the user confirms their tests pass.
#
# USAGE:
#   commit-changes.sh [--json] <commit-message>
#
# ARGUMENTS:
#   commit-message  — Quoted Conventional Commits message (Claude generates this).
#                     Format: type(scope): description
#                     Example: feat(cli): add --json flag to output
#
# OPTIONS:
#   --json   Emit result as JSON to stdout; all other messages go to stderr.
#
# OUTPUT — text mode:
#   [ok]    Committed: abc1234 — feat(cli): add --json flag to output
#   [error] Commit message format invalid. Expected: type(scope): description
#   [error] Nothing is staged. Stage your changes before committing.
#
# OUTPUT — json mode:
#   {"status": "ok", "message": "...", "committed": true, "sha": "abc1234", "branch": "feat-003-name", "commit_message": "feat: initial implementation"}
#   {"status": "error", "message": "..."}
#
# EXIT CODES:
#   0 — commit and push succeeded
#   1 — validation failed, nothing staged, or unexpected error

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
# Extracts the commit message positional arg. --json is re-encountered here
# and skipped — it was already handled by parse_common_args above.
# ---------------------------------------------------------------------------
commit_message=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --json)
      # Already handled by parse_common_args; skip.
      shift
      ;;
    -*)
      # Unknown flag — silently ignore to stay forward-compatible.
      shift
      ;;
    *)
      # Positional argument: the commit message (take the first one found).
      if [[ -z "$commit_message" ]]; then
        commit_message="$1"
      fi
      shift
      ;;
  esac
done

# ---------------------------------------------------------------------------
# Input validation: require a non-empty commit message.
# ---------------------------------------------------------------------------
if [[ -z "$commit_message" ]]; then
  echo "Error: missing required argument <commit-message>" >&2
  echo "Usage: commit-changes.sh [--json] <commit-message>" >&2
  echo "Example: commit-changes.sh \"feat(cli): add --json flag to output\"" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Conventional Commits format validation.
# Pattern: type(optional-scope): description (description 1–72 chars)
# This check runs before any git operation so that an invalid message
# is rejected without touching the repository.
#
# NOTE: The regex variable must NOT be quoted in the =~ test; quoting it
# would cause bash to treat it as a literal string rather than a pattern.
# ---------------------------------------------------------------------------
COMMIT_PATTERN='^(feat|fix|docs|style|refactor|test|chore|build|ci|perf|revert)(\(.+\))?: .{1,72}$'
if [[ ! "$commit_message" =~ $COMMIT_PATTERN ]]; then
  output_result "error" \
    "Commit message format invalid. Expected: type(scope): description — e.g. feat(cli): add --json flag"
  exit 1
fi

# ---------------------------------------------------------------------------
# Staged diff check.
# git diff --staged --stat shows a human-readable summary of staged files.
# If the output is empty, nothing is staged and we should not create an empty
# commit. Diagnostic output always goes to stderr so it never taints JSON stdout.
# ---------------------------------------------------------------------------
staged="$(git diff --staged --stat)"
if [[ -z "$staged" ]]; then
  output_result "error" \
    "Nothing is staged. Use git add to stage your changes before committing."
  exit 1
fi

echo "Staged changes:" >&2
echo "$staged" >&2

# ---------------------------------------------------------------------------
# Commit.
# set -euo pipefail (inherited from common.sh) ensures any failure here exits
# immediately with a non-zero code rather than silently continuing.
# ---------------------------------------------------------------------------
git commit -m "$commit_message"

# ---------------------------------------------------------------------------
# Push.
# --set-upstream is idempotent: sets the remote tracking branch on the first
# push, and is effectively a no-op on subsequent pushes if upstream is already
# set. This handles the case where create-feature-branch.sh created a local
# branch that has never yet been pushed to origin.
# ---------------------------------------------------------------------------
current_branch="$(git rev-parse --abbrev-ref HEAD)"
git push --set-upstream origin "$current_branch"

# ---------------------------------------------------------------------------
# Capture the short SHA immediately after commit so the output reflects the
# exact commit that was just created.
# ---------------------------------------------------------------------------
sha="$(git rev-parse --short HEAD)"

output_result "ok" \
  "Committed: ${sha} — ${commit_message}" \
  ", \"committed\": true, \"sha\": \"${sha}\", \"branch\": \"${current_branch}\", \"commit_message\": \"${commit_message}\""
