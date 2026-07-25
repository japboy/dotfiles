#!/usr/bin/env bash
# Validate and save a context summary to Desktop without overwriting.
# Usage: <skill-root>/scripts/save-summary.sh <summary-title> < summary.md
# Output: Saves to ~/Desktop/summary-202501191430-api-refactoring-progress.md
#
# Cross-platform support:
#   - macOS: ~/Desktop
#   - Linux: Uses xdg-user-dir DESKTOP (respects locale)
#   - WSL: /mnt/c/Users/<user>/Desktop

set -euo pipefail
umask 077

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <summary-title> < summary.md" >&2
    exit 1
fi

if [[ -t 0 ]]; then
    echo "Error: Summary content must be supplied on stdin" >&2
    exit 1
fi

title="$1"

# Validate title: lowercase, hyphens, no special characters
if [[ ! "$title" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo "Error: Title must use lowercase letters, numbers, and single internal hyphens" >&2
    exit 1
fi

# Validate title length (max 50 characters)
if [[ ${#title} -gt 50 ]]; then
    echo "Error: Title must be 50 characters or less (got ${#title})" >&2
    exit 1
fi

# Determine Desktop directory (cross-platform)
if command -v xdg-user-dir &>/dev/null; then
    # Linux with XDG support
    desktop_dir=$(xdg-user-dir DESKTOP)
elif [[ -d "/mnt/c/Users" ]]; then
    # WSL: use Windows Desktop
    win_user=$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r')
    desktop_dir="/mnt/c/Users/${win_user}/Desktop"
else
    # macOS or fallback
    desktop_dir="${HOME}/Desktop"
fi

# Ensure Desktop directory exists
if [[ ! -d "${desktop_dir}" ]]; then
    echo "Error: Desktop directory not found: ${desktop_dir}" >&2
    exit 1
fi
if [[ ! -w "${desktop_dir}" ]]; then
    echo "Error: Desktop directory is not writable: ${desktop_dir}" >&2
    exit 1
fi

# Generate timestamp in YYYYMMDDHHmm format
timestamp=$(date +"%Y%m%d%H%M")

# Generate full filepath with summary- prefix
filepath="${desktop_dir}/summary-${timestamp}-${title}.md"

# Read and validate before publishing. The temporary file is created in the
# destination directory so the final hard link is atomic on the same filesystem.
tempfile=$(mktemp "${desktop_dir}/.handoff-summary.XXXXXX")
cleanup() {
    if [[ -n "${tempfile:-}" && -e "${tempfile}" ]]; then
        rm -f -- "${tempfile}"
    fi
}
trap cleanup EXIT HUP INT TERM

cat > "${tempfile}"

if [[ ! -s "${tempfile}" ]]; then
    echo "Error: Summary content is empty" >&2
    exit 1
fi

if ! awk '
BEGIN {
    required["## Entities"] = 1
    required["## States"] = 1
    required["## Actions"] = 1
    required["## Constraints"] = 1
}
/^## / {
    current = ($0 in required) ? $0 : ""
    if (current != "") seen[current]++
    next
}
current != "" && $0 !~ /^[[:space:]]*$/ { content[current] = 1 }
END {
    failed = 0
    for (heading in required) {
        if (seen[heading] != 1 || content[heading] != 1) {
            print "Error: Required heading must occur once with non-empty content: " heading > "/dev/stderr"
            failed = 1
        }
    }
    exit failed
}
' "${tempfile}"; then
    exit 1
fi

# ln creates the destination atomically and fails when it already exists.
if ! ln "${tempfile}" "${filepath}"; then
    echo "Error: Refusing to overwrite existing summary: ${filepath}" >&2
    exit 1
fi
rm -f -- "${tempfile}"
tempfile=""

# Output the saved filepath
echo "${filepath}"
