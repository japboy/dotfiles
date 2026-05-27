#!/usr/bin/env bash
# Render the mechanical part of a batch summary for the
# iterating-issue-review skill.
#
# Usage:
#   summarize_batch.sh --issue <N> --round <K> --concurrency <C>
#                      [--repo <owner/name>]
#
# Reads round-<K> .. round-<K+C-1> under the batch's round root and
# emits the mechanical header (header bullets only, no per-round
# content) to stdout. The orchestrator pastes this verbatim, then
# appends the Findings table, per-finding sections, Cross-round
# notes (when needed), and User decisions per the Output Format
# defined in SKILL.md, and persists the combined result to
# `<round_root>/consolidated-for-batch-<K>.md`.
#
# This script never edits the issue, never reads any reviewer's
# stdout (raw.txt) for content, and never deduplicates findings;
# all consolidation is the orchestrator's job.

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "${script_dir}/lib.sh"

usage() { iir_print_usage "$0"; }

issue=""
round=""
concurrency=""
repo=""

while [ $# -gt 0 ]; do
    case "$1" in
        --issue)       issue="${2:-}";       shift 2 ;;
        --round)       round="${2:-}";       shift 2 ;;
        --concurrency) concurrency="${2:-}"; shift 2 ;;
        --repo)        repo="${2:-}";        shift 2 ;;
        -h|--help)     usage; exit 0 ;;
        *)
            echo "unknown argument: $1" >&2
            usage >&2
            exit 64
            ;;
    esac
done

for name in issue round concurrency; do
    value="$(eval "printf '%s' \"\${$name}\"")"
    if [ -z "$value" ]; then
        echo "missing required argument: --${name}" >&2
        exit 64
    fi
done

if ! [[ "$issue" =~ ^[0-9]+$ ]]; then
    echo "--issue must be a positive integer, got '${issue}'" >&2
    exit 64
fi
if ! [[ "$round" =~ ^[0-9]+$ ]] || [ "$round" -lt 1 ]; then
    echo "--round must be a positive integer (>= 1), got '${round}'" >&2
    exit 64
fi
if ! [[ "$concurrency" =~ ^[0-9]+$ ]] || [ "$concurrency" -lt 1 ]; then
    echo "--concurrency must be a positive integer (>= 1), got '${concurrency}'" >&2
    exit 64
fi

if [ -z "$repo" ]; then
    if ! command -v gh >/dev/null 2>&1; then
        echo "gh not on PATH and --repo not given; cannot resolve repo" >&2
        exit 72
    fi
    repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

tmpdir="$(iir_detect_tmpdir)" || {
    echo "cannot detect OS temp directory" >&2
    exit 74
}
round_root="$(iir_round_root "$tmpdir" "$repo" "$issue")"

batch_start="$round"
batch_end=$((batch_start + concurrency - 1))

# Count occurrences of a fixed-string tag in a file. Returns 0 when
# the file is missing.
count_tag() {
    local tag="$1"
    local file="$2"
    if [ ! -f "$file" ]; then
        printf '0'
        return 0
    fi
    local n
    n="$( { grep -oF "$tag" "$file" 2>/dev/null || true; } | wc -l | tr -d ' ')"
    printf '%s' "${n:-0}"
}

# True when the file contains a line whose contents are exactly
# `[CONVERGED]` (allowing only trailing whitespace).
file_converged() {
    local file="$1"
    [ -f "$file" ] && grep -Eq '^\[CONVERGED\][[:space:]]*$' "$file"
}

# Pretty-print the trimmed contents of round-<n>/reviewer, or
# "unknown" when missing.
round_reviewer() {
    local rd="$1"
    if [ -f "${rd}/reviewer" ]; then
        tr -d '[:space:]' < "${rd}/reviewer"
    else
        printf 'unknown'
    fi
}

reviewer_count_codex=0
reviewer_count_claude=0
reviewer_count_unknown=0
total_blocker=0
total_important=0
total_question=0
total_suggestion=0
total_nit=0
all_converged=1

n="$batch_start"
while [ "$n" -le "$batch_end" ]; do
    rd="${round_root}/round-${n}"
    final="${rd}/final.md"
    rev="$(round_reviewer "$rd")"
    case "$rev" in
        codex)  reviewer_count_codex=$((reviewer_count_codex + 1)) ;;
        claude) reviewer_count_claude=$((reviewer_count_claude + 1)) ;;
        *)      reviewer_count_unknown=$((reviewer_count_unknown + 1)) ;;
    esac

    total_blocker=$((total_blocker + $(count_tag '[BLOCKER]' "$final")))
    total_important=$((total_important + $(count_tag '[IMPORTANT]' "$final")))
    total_question=$((total_question + $(count_tag '[QUESTION]' "$final")))
    total_suggestion=$((total_suggestion + $(count_tag '[SUGGESTION]' "$final")))
    total_nit=$((total_nit + $(count_tag '[NIT]' "$final")))

    if ! file_converged "$final"; then
        all_converged=0
    fi
    n=$((n + 1))
done

if [ "$all_converged" -eq 1 ] \
    && [ "$total_blocker" -eq 0 ] \
    && [ "$total_important" -eq 0 ] \
    && [ "$total_question" -eq 0 ]; then
    converged="YES"
else
    converged="NO"
fi

mix_parts=""
append_mix() {
    local part="$1"
    if [ -n "$mix_parts" ]; then
        mix_parts="${mix_parts}, ${part}"
    else
        mix_parts="$part"
    fi
}
if [ "$reviewer_count_codex" -gt 0 ]; then
    append_mix "codex × ${reviewer_count_codex}"
fi
if [ "$reviewer_count_claude" -gt 0 ]; then
    append_mix "claude × ${reviewer_count_claude}"
fi
if [ "$reviewer_count_unknown" -gt 0 ]; then
    append_mix "unknown × ${reviewer_count_unknown}"
fi
if [ -z "$mix_parts" ]; then
    mix_parts="(none)"
fi

# Header (only). The orchestrator appends the Findings table,
# per-finding sections, Cross-round notes, and User decisions
# below this header. Per-round `final.md` content is not pasted
# here; the table's Source column links to each round's file.
printf '# Iterating Issue Review — Batch %s..%s\n\n' "$batch_start" "$batch_end"
printf -- '- Issue: %s#%s\n' "$repo" "$issue"
printf -- '- Concurrency: %s\n' "$concurrency"
printf -- '- Reviewer mix: %s\n' "$mix_parts"
printf -- '- Convergence: %s\n' "$converged"
printf -- '- Severity totals: BLOCKER=%d IMPORTANT=%d QUESTION=%d SUGGESTION=%d NIT=%d\n' \
    "$total_blocker" "$total_important" "$total_question" "$total_suggestion" "$total_nit"
printf -- '- Round directory: [%s](file://%s)\n' "$round_root" "$round_root"
