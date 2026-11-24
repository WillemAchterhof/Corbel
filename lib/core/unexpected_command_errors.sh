#!/usr/bin/env bash

# ==============================================================================
# Unexpected Command Errors
# ==============================================================================
# lib/core/unexpected_command_errors.sh
#
# Provides the centralized ERR trap handler.
#
# Responsibilities:
#   - Handle unexpected command failures
#   - Identify common command execution failures
#   - Capture the failing command and source location
#   - Report the original exit status
#
# Constraints:
#   - Sourced library: definitions only.
#   - Defines the ERR trap handler only.
#   - Does not install traps.
#   - Reuses error_report() for consistent formatting.
#   - Preserves the original exit status.
# ==============================================================================

# ==============================================================================
# Unexpected Command Failure Handler
# ==============================================================================

trap_err() {
    local exit_code="$1"

    trap - ERR

    local failing_command="${2:-unknown}"
    local line="${3:-unknown}"
    local call_line="${4:-unknown}"

    local file="${BASH_SOURCE[1]:-$PROJECT_DIR/unknown}"
    local caller_file="${BASH_SOURCE[2]:-$PROJECT_DIR/unknown}"
    local caller_func="${FUNCNAME[2]:-main}"

    local title

    case "$exit_code" in
        126)
            title="Command not executable"
            ;;
        127)
            title="Command not found"
            ;;
        *)
            title="Command failed"
            ;;
    esac

    error_report \
        "$title" \
        "Command: $failing_command" \
        "$file" \
        "$line" \
        "$caller_file:$call_line ($caller_func)"

    exit "$exit_code"
}