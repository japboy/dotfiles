#!/usr/bin/env bash
# Review batch entry point for the iterating-issue-review skill.
#
# This is the single user-facing entry point. `run_review.sh` is an
# internal worker that this script dispatches; direct invocation of
# `run_review.sh` is supported for debugging only.
#
# Usage:
#   run_batch.sh --main <codex|claude> --concurrency <N> \
#                --issue <N> --round <K> \
#                [--repo <owner/name>] [--dry-run]
#
# A batch consumes `concurrency` consecutive round numbers starting at
# `--round K`, i.e. rounds K, K+1, ..., K+N-1. Each round maps to one
# reviewer worker and its own `round-<n>/` directory; workers share no
# state mid-batch. The next invocation should pass `--round (K + N)`.
#
# Reviewer distribution inside the batch:
#   others = 0                         when N == 1
#   others = max(1, round(N * 0.3))    when N >= 2
#   main   = N - others
# The "other" reviewer is claude when --main is codex, and vice versa.
# Main slots take the lower round numbers; other slots take the upper.
#
# Before dispatch, the orchestrator concatenates the previous batch's
# final.md files (rounds max(1, K-N) .. K-1) into a single prior
# feedback file and passes it to every worker via
# --prior-feedback-file, so all workers in the batch see the same
# prior context and never race on each other's results.
#
# On success prints one TSV line per round to stdout:
#   <round>\t<reviewer>\t<round-dir>
# Exits non-zero if any worker fails; surviving rounds' artifacts
# remain on disk for inspection.
#
# --dry-run prints the planned rounds to stdout without dispatching.

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "${script_dir}/lib.sh"

usage() { iir_print_usage "$0"; }

main=""
concurrency=""
issue=""
round=""
repo=""
dry_run=0

while [ $# -gt 0 ]; do
    case "$1" in
        --main)        main="${2:-}";        shift 2 ;;
        --concurrency) concurrency="${2:-}"; shift 2 ;;
        --issue)       issue="${2:-}";       shift 2 ;;
        --round)       round="${2:-}";       shift 2 ;;
        --repo)        repo="${2:-}";        shift 2 ;;
        --dry-run)     dry_run=1;            shift ;;
        -h|--help)     usage; exit 0 ;;
        *)
            echo "unknown argument: $1" >&2
            usage >&2
            exit 64
            ;;
    esac
done

for name in main concurrency issue round; do
    value="$(eval "printf '%s' \"\${$name}\"")"
    if [ -z "$value" ]; then
        echo "missing required argument: --${name}" >&2
        exit 64
    fi
done

case "$main" in
    codex)  other="claude" ;;
    claude) other="codex"  ;;
    *)
        echo "--main must be 'codex' or 'claude', got '${main}'" >&2
        exit 64
        ;;
esac

if ! [[ "$concurrency" =~ ^[0-9]+$ ]] || [ "$concurrency" -lt 1 ]; then
    echo "--concurrency must be a positive integer (>= 1), got '${concurrency}'" >&2
    exit 64
fi

if ! [[ "$issue" =~ ^[0-9]+$ ]]; then
    echo "--issue must be a positive integer, got '${issue}'" >&2
    exit 64
fi

if ! [[ "$round" =~ ^[0-9]+$ ]] || [ "$round" -lt 1 ]; then
    echo "--round must be a positive integer (>= 1), got '${round}'" >&2
    exit 64
fi

if [ "$concurrency" -gt 5 ]; then
    echo "notice: --concurrency=${concurrency} multiplies reviewer cost by ${concurrency}x and may trip API rate limits" >&2
fi

others_count="$(iir_others_count "$concurrency")"
main_count=$((concurrency - others_count))
batch_start="$round"
batch_end=$((batch_start + concurrency - 1))

# Assign rounds to reviewers in a stable order: main on the lower
# rounds, other on the upper.
rounds=()
reviewers=()
i=0
while [ "$i" -lt "$concurrency" ]; do
    r=$((batch_start + i))
    if [ "$i" -lt "$main_count" ]; then
        reviewer="$main"
    else
        reviewer="$other"
    fi
    rounds+=("$r")
    reviewers+=("$reviewer")
    i=$((i + 1))
done

if [ "$dry_run" -eq 1 ]; then
    printf 'plan issue=%s main=%s concurrency=%s rounds=%s..%s (main=%d other=%d)\n' \
        "$issue" "$main" "$concurrency" "$batch_start" "$batch_end" \
        "$main_count" "$others_count"
    i=0
    while [ "$i" -lt "${#rounds[@]}" ]; do
        printf '  round=%s  reviewer=%s\n' "${rounds[$i]}" "${reviewers[$i]}"
        i=$((i + 1))
    done
    printf 'next-round: %s\n' "$((batch_end + 1))"
    exit 0
fi

run_review="${script_dir}/run_review.sh"
if [ ! -x "$run_review" ]; then
    echo "helper not executable: $run_review" >&2
    exit 70
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
mkdir -p "$round_root"

# Compose the batch's prior-feedback file from the previous batch's
# rounds (max(1, K-N) .. K-1). Empty when no prior rounds exist.
prior_blob="${round_root}/prior-for-batch-${batch_start}.md"
: > "$prior_blob"
prior_from=$((batch_start - concurrency))
if [ "$prior_from" -lt 1 ]; then
    prior_from=1
fi
prior_to=$((batch_start - 1))
if [ "$prior_to" -ge "$prior_from" ] && [ "$prior_to" -ge 1 ]; then
    n="$prior_from"
    while [ "$n" -le "$prior_to" ]; do
        candidate="${round_root}/round-${n}/final.md"
        if [ -s "$candidate" ]; then
            {
                printf '### From: round-%s\n\n' "$n"
                cat "$candidate"
                printf '\n\n'
            } >> "$prior_blob"
        fi
        n=$((n + 1))
    done
fi

# Dispatch workers, each claiming a distinct round number.
pids=()
logs=()
i=0
while [ "$i" -lt "${#rounds[@]}" ]; do
    r="${rounds[$i]}"
    reviewer="${reviewers[$i]}"
    mkdir -p "${round_root}/round-${r}"
    log_file="${round_root}/round-${r}/dispatch.log"
    logs+=("$log_file")
    (
        "$run_review" \
            --reviewer "$reviewer" \
            --issue "$issue" \
            --round "$r" \
            --repo "$repo" \
            --prior-feedback-file "$prior_blob"
    ) > "$log_file" 2>&1 &
    pids+=("$!")
    echo "started round=${r} reviewer=${reviewer} pid=$!" >&2
    i=$((i + 1))
done

# Wait and tally.
failed=0
i=0
while [ "$i" -lt "${#pids[@]}" ]; do
    pid="${pids[$i]}"
    r="${rounds[$i]}"
    reviewer="${reviewers[$i]}"
    log_file="${logs[$i]}"
    if wait "$pid"; then
        echo "round=${r} reviewer=${reviewer}: ok" >&2
    else
        status=$?
        echo "round=${r} reviewer=${reviewer}: failed (exit ${status}); see ${log_file}" >&2
        failed=1
    fi
    i=$((i + 1))
done

# Emit TSV: <round>\t<reviewer>\t<round-dir>
i=0
while [ "$i" -lt "${#rounds[@]}" ]; do
    r="${rounds[$i]}"
    reviewer="${reviewers[$i]}"
    printf '%s\t%s\t%s/round-%s\n' "$r" "$reviewer" "$round_root" "$r"
    i=$((i + 1))
done

exit "$failed"
