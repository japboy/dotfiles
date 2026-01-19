#!/bin/bash
# Save context summary to Desktop with timestamped filename
# Usage: echo "content" | ./save-summary.sh <summary-title>
#    or: ./save-summary.sh <summary-title> < content.md
# Example: echo "# Summary" | ./save-summary.sh api-refactoring-progress
# Output: Saves to ~/Desktop/summary-202501191430-api-refactoring-progress.md
#
# Cross-platform support:
#   - macOS: ~/Desktop
#   - Linux: Uses xdg-user-dir DESKTOP (respects locale)
#   - WSL: /mnt/c/Users/<user>/Desktop

set -euo pipefail

if [[ $# -lt 1 ]]; then
    echo "Usage: echo \"content\" | $0 <summary-title>" >&2
    echo "Example: echo \"# Summary\" | $0 api-refactoring-progress" >&2
    exit 1
fi

title="$1"

# Validate title: lowercase, hyphens, no special characters
if [[ ! "$title" =~ ^[a-z0-9-]+$ ]]; then
    echo "Error: Title must contain only lowercase letters, numbers, and hyphens" >&2
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

# Generate timestamp in YYYYMMDDHHmm format
timestamp=$(date +"%Y%m%d%H%M")

# Generate full filepath with summary- prefix
filepath="${desktop_dir}/summary-${timestamp}-${title}.md"

# Read from stdin and write to file
cat > "${filepath}"

# Output the saved filepath
echo "${filepath}"
