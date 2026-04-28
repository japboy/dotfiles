# shellcheck shell=bash
# Shared helpers for the iterating-issue-review skill.
# This file is intended to be `source`d by other scripts in the same dir.
# It must not be executed directly.

# Print the OS temp directory in this fixed priority order:
#   1. $TMPDIR (honored by macOS per-user temp dirs)
#   2. `getconf DARWIN_USER_TEMP_DIR` (macOS fallback)
#   3. /tmp (Linux fallback)
# Returns non-zero when nothing usable is found.
iir_detect_tmpdir() {
    if [ -n "${TMPDIR:-}" ] && [ -d "$TMPDIR" ]; then
        printf '%s' "${TMPDIR%/}"
        return 0
    fi
    if command -v getconf >/dev/null 2>&1; then
        local darwin_tmp
        darwin_tmp="$(getconf DARWIN_USER_TEMP_DIR 2>/dev/null || true)"
        if [ -n "$darwin_tmp" ] && [ -d "$darwin_tmp" ]; then
            printf '%s' "${darwin_tmp%/}"
            return 0
        fi
    fi
    if [ -d /tmp ]; then
        printf '%s' /tmp
        return 0
    fi
    return 1
}

# Compose the per-issue round root path:
#   <tmpdir>/iterating-issue-review/<repo-slug>/issue-<N>
# Arguments: <tmpdir> <repo:owner/name> <issue>
iir_round_root() {
    local tmpdir="$1"
    local repo="$2"
    local issue="$3"
    local slug="${repo//\//-}"
    printf '%s/iterating-issue-review/%s/issue-%s' "${tmpdir%/}" "$slug" "$issue"
}

# Compute how many workers should use the non-main reviewer, given a
# total concurrency count. Uses round-half-up at 30%, with a floor of 1
# whenever N >= 2 (so there is always at least one dissenting voice).
# Arguments: <concurrency>
iir_others_count() {
    local n="$1"
    if [ "$n" -le 1 ]; then
        printf '0'
        return 0
    fi
    awk -v n="$n" 'BEGIN {
        v = int(n * 0.3 + 0.5)
        if (v < 1) v = 1
        printf "%d", v
    }'
}

# Print a usage block extracted from the leading comment of a script.
# The leading shebang line is skipped. Stops at the first non-comment
# line.
# Arguments: <script-path>
iir_print_usage() {
    local path="$1"
    awk '
        NR == 1 && /^#!/ { next }
        /^#/ { sub(/^# ?/, ""); print; next }
        { exit }
    ' "$path"
}
