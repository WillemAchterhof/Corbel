#!/usr/bin/env bash

# ==============================================================================
# Shared Error Handling
# ==============================================================================
# lib/core/error_handling.sh
#
# Responsibilities:
#   - Provide consistent error reporting
#   - Display fatal errors
#   - Log fatal errors
#   - Terminate execution for deliberate fatal errors
#
# Constraints:
#   - Defines internal functions only.
#   - Does not install traps.
#   - Does not define specialized error messages.
# ==============================================================================


# ==============================================================================
# Internal Error Reporter
# ==============================================================================

_err_report() {
    local report="$1"

    printf '%s\n' "$report" >&2
    { printf '%s\n' "$report" >> "$LOG_FILE"; } 2>/dev/null || true
}


# ==============================================================================
# Fatal Error Handler
# ==============================================================================

_err_die() {
    local title="$1"
    local detail_label="$2"
    local detail="$3"
    local caller_file="$4"
    local caller_line="$5"
    local caller_func="$6"
    local exit_code="${7:-1}"

    local relative_caller="${caller_file#"$PROJECT_DIR"/}"
    local report

    printf -v report \
        '[FATAL] Error\t: %s\n\t%s\t: %s\n\tCaller\t: %s:%s (%s)' \
        "$title" \
        "$detail_label" \
        "$detail" \
        "$relative_caller" \
        "$caller_line" \
        "$caller_func"

    _err_report "$report"

    exit "$exit_code"
}