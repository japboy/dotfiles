#!/usr/bin/env bash
# Allocate K consecutive finding numbers across batches for an issue.
#
# Usage:
#   allocate_finding_numbers.sh --issue <N> --count <K>
#                               [--repo <owner/name>]
#
# Reads <round_root>/finding-counter (default 1 when absent or
# invalid), prints K numbers (one per line) starting from the
# current counter value, and writes the post-allocation counter
# (current + K) back to the file.
#
# Purpose: makes the `#` column in batch reports a stable
# cross-batch identifier. Numbers never repeat across batches for
# the same issue, even when the orchestrator and reviewer sessions
# restart.
#
# The counter lives at <round_root>/finding-counter and survives
# alongside the round-N/ and *-for-batch-K.md artifacts. Delete it
# only when intentionally restarting the issue's review history.

set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
# shellcheck disable=SC1091
. "${script_dir}/lib.sh"

usage() { iir_print_usage "$0"; }

issue=""
count=""
repo=""

while [ $# -gt 0 ]; do
    case "$1" in
        --issue)  issue="${2:-}";  shift 2 ;;
        --count)  count="${2:-}";  shift 2 ;;
        --repo)   repo="${2:-}";   shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *)
            echo "unknown argument: $1" >&2
            usage >&2
            exit 64
            ;;
    esac
done

for name in issue count; do
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
if ! [[ "$count" =~ ^[0-9]+$ ]] || [ "$count" -lt 1 ]; then
    echo "--count must be a positive integer (>= 1), got '${count}'" >&2
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
mkdir -p "$round_root"
counter_file="${round_root}/finding-counter"

current=1
if [ -f "$counter_file" ]; then
    raw="$(tr -d '[:space:]' < "$counter_file")"
    if [[ "$raw" =~ ^[0-9]+$ ]] && [ "$raw" -ge 1 ]; then
        current="$raw"
    fi
fi

i=0
while [ "$i" -lt "$count" ]; do
    printf '%s\n' "$((current + i))"
    i=$((i + 1))
done

new_counter=$((current + count))
printf '%s\n' "$new_counter" > "$counter_file"
