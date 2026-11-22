#!/usr/bin/env bash

# ==============================================================================
# Unexpected Command Errors
# ==============================================================================
# lib/core/unexpected_command_errors.sh
#
# Responsibilities:
#   - Handle unexpected command failures through trap_err
#   - Identify common command execution failures
#   - Report the failing command and its caller
#
# Constraints:
#   - Defines the ERR trap handler only.
#   - Does not install traps.
#   - Uses the shared error reporter from error_handling.sh.
#   - Preserves the original exit status.
# ==============================================================================


# ==============================================================================
# Unexpected Command Failure Handler
# ==============================================================================

trap_err() {
    trap - ERR

    local exit_code="$1"
    local failing_command="${2:-unknown}"
    local line="${3:-unknown}"
    local call_line="${4:-unknown}"

    local file="${BASH_SOURCE[1]:-$PROJECT_DIR/unknown}"
    local caller_file="${BASH_SOURCE[2]:-$PROJECT_DIR/unknown}"
    local caller_func="${FUNCNAME[2]:-main}"

    file="${file#"$PROJECT_DIR"/}"
    caller_file="${caller_file#"$PROJECT_DIR"/}"

    local title="Command failed."

    if (( exit_code == 127 )); then
        title="Command not found."
    elif (( exit_code == 126 )); then
        title="Command not executable."
    fi

    local report

    printf -v report \
        '[FATAL] Error\t: %s\n\tCommand\t: %s\n\tFile\t: %s:%s\n\tCaller\t: %s:%s (%s)' \
        "$title" \
        "$failing_command" \
        "$file" \
        "$line" \
        "$caller_file" \
        "$call_line" \
        "$caller_func"

    _err_report "$report"

    exit "$exit_code"
}