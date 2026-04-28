#!/usr/bin/env bash
# Internal worker for the iterating-issue-review skill.
#
# `run_batch.sh` is the documented entry point for users; this script
# is the per-round worker it dispatches. Direct invocation is
# supported only for debugging.
#
# Usage:
#   run_review.sh --reviewer <codex|claude> --issue <N> --round <K>
#                 [--repo <owner/name>]
#                 [--prior-feedback-file <path>]
#
# One invocation runs one reviewer CLI against the current issue body
# and writes artifacts into round-<K>/. A round number identifies one
# reviewer pass; a batch of size N assigns distinct round numbers
# (K..K+N-1) to its workers, so there is never more than one
# reviewer pass per round directory.
#
# On success prints the round working directory path to stdout and
# exits 0. The directory contains:
#   current_body.md   issue body at the start of the round
#   prompt.md         prompt sent to the reviewer
#   raw.txt           full reviewer stdout (diagnostic)
#   final.md          reviewer's final message (authoritative)
#   reviewer          name of the reviewer CLI used (audit)
#
# Prior-round feedback handling:
#   --prior-feedback-file <path>   use the given file verbatim as the
#                                  prior-feedback block in the prompt.
#                                  Empty or missing file is treated as
#                                  "(no prior round)".
#   (no flag)                      fall back to the most recent
#                                  round-<M>/final.md with M < K.

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "${script_dir}/lib.sh"

usage() { iir_print_usage "$0"; }

reviewer=""
issue=""
round=""
repo=""
prior_feedback_file=""

while [ $# -gt 0 ]; do
    case "$1" in
        --reviewer)             reviewer="${2:-}";             shift 2 ;;
        --issue)                issue="${2:-}";                shift 2 ;;
        --round)                round="${2:-}";                shift 2 ;;
        --repo)                 repo="${2:-}";                 shift 2 ;;
        --prior-feedback-file)  prior_feedback_file="${2:-}";  shift 2 ;;
        -h|--help)              usage; exit 0 ;;
        *)
            echo "unknown argument: $1" >&2
            usage >&2
            exit 64
            ;;
    esac
done

for name in reviewer issue round; do
    value="$(eval "printf '%s' \"\${$name}\"")"
    if [ -z "$value" ]; then
        echo "missing required argument: --${name}" >&2
        exit 64
    fi
done

case "$reviewer" in
    codex|claude) ;;
    *)
        echo "--reviewer must be 'codex' or 'claude', got '${reviewer}'" >&2
        exit 64
        ;;
esac

if ! [[ "$issue" =~ ^[0-9]+$ ]]; then
    echo "--issue must be a positive integer, got '${issue}'" >&2
    exit 64
fi

if ! [[ "$round" =~ ^[0-9]+$ ]] || [ "$round" -lt 1 ]; then
    echo "--round must be a positive integer (>= 1), got '${round}'" >&2
    exit 64
fi

if [ -n "$prior_feedback_file" ] && [ ! -e "$prior_feedback_file" ]; then
    echo "--prior-feedback-file not found: $prior_feedback_file" >&2
    exit 64
fi

for tool in gh python3; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "required tool not found on PATH: ${tool}" >&2
        exit 72
    fi
done

if [ "$reviewer" = "claude" ] && ! command -v jq >/dev/null 2>&1; then
    echo "jq is required when --reviewer is 'claude'" >&2
    exit 72
fi

if ! command -v "$reviewer" >/dev/null 2>&1; then
    echo "reviewer CLI not found on PATH: ${reviewer}" >&2
    exit 72
fi

if [ -z "$repo" ]; then
    repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

tmpdir="$(iir_detect_tmpdir)" || {
    echo "cannot detect OS temp directory" >&2
    exit 74
}

round_root="$(iir_round_root "$tmpdir" "$repo" "$issue")"
workdir="${round_root}/round-${round}"
mkdir -p "$workdir"

gh issue view "$issue" --repo "$repo" --json body -q .body \
    > "${workdir}/current_body.md"

# Resolve the prior-feedback source file.
effective_prior=""
if [ -n "$prior_feedback_file" ]; then
    effective_prior="$prior_feedback_file"
else
    prior_candidate=$((round - 1))
    while [ "$prior_candidate" -ge 1 ]; do
        candidate="${round_root}/round-${prior_candidate}/final.md"
        if [ -s "$candidate" ]; then
            effective_prior="$candidate"
            break
        fi
        prior_candidate=$((prior_candidate - 1))
    done
fi

template_path="${script_dir}/../references/reviewer_prompt.md"

python3 - "$template_path" "${workdir}/current_body.md" \
        "${effective_prior:-}" "${workdir}/prompt.md" \
        "$repo" "$issue" "$round" <<'PY'
import pathlib
import sys

tpl_path, body_path, prior_path, out_path, repo, issue, round_ = sys.argv[1:8]

raw = pathlib.Path(tpl_path).read_text()
begin = "---BEGIN-TEMPLATE---\n"
end = "\n---END-TEMPLATE---"
if begin not in raw or end not in raw:
    raise SystemExit(f"template markers missing in {tpl_path}")
template = raw.split(begin, 1)[1].split(end, 1)[0]

body = pathlib.Path(body_path).read_text()
if prior_path:
    prior = pathlib.Path(prior_path).read_text().strip() or "(no prior round)"
else:
    prior = "(no prior round)"

prompt = (template
          .replace("{{repo}}", repo)
          .replace("{{issue}}", issue)
          .replace("{{round}}", round_)
          .replace("{{current_body}}", body)
          .replace("{{prior_feedback}}", prior))

pathlib.Path(out_path).write_text(prompt)
PY

printf '%s\n' "$reviewer" > "${workdir}/reviewer"

# Always run both reviewer CLIs at their highest reasoning effort.
# For Codex that is `model_reasoning_effort = "xhigh"`, injected via
# `-c key="value"` (TOML value). For Claude Code that is
# `--effort max`. Keep these fixed so review quality does not drift
# with local config changes.
case "$reviewer" in
    codex)
        codex exec \
            -c 'model_reasoning_effort="xhigh"' \
            -o "${workdir}/final.md" \
            "$(cat "${workdir}/prompt.md")" \
            > "${workdir}/raw.txt" 2>&1
        ;;
    claude)
        claude -p \
            --effort max \
            --output-format json \
            "$(cat "${workdir}/prompt.md")" \
            > "${workdir}/raw.txt" 2>&1
        jq -r '.result // ""' "${workdir}/raw.txt" > "${workdir}/final.md"
        ;;
esac

if [ ! -s "${workdir}/final.md" ]; then
    echo "reviewer produced no final message; see ${workdir}/raw.txt" >&2
    exit 75
fi

printf '%s\n' "$workdir"
