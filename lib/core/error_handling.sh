#!/usr/bin/env bash

# ==============================================================================
# Shared Error Handling
# ==============================================================================
# lib/core/error_handling.sh
#
# Provides centralized error reporting and deliberate fatal errors.
#
# Responsibilities:
#   - Format structured fatal error reports
#   - Write error reports to stderr and the project log
#   - Provide a shared fatal error function
#   - Mark deliberately reported fatal errors
#
# Constraints:
#   - Sourced library: definitions only.
#   - Does not install traps.
#   - Does not define specialized error messages.
#   - Never exits directly.
#   - Expects LOG_FILE and PROJECT_DIR to be initialized.
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
# Structured Error Report
# ==============================================================================

error_report() {
    local title="$1"
    local description="$2"
    local file="${3:-unknown}"
    local line="${4:-unknown}"
    local caller="${5:-unknown}"

    file="${file#"$PROJECT_DIR"/}"

    local report

    printf -v report \
        '[FATAL] Error\t: %s\n\tDetails\t: %s\n\tFile\t: %s:%s\n\tCaller\t: %s' \
        "$title" \
        "$description" \
        "$file" \
        "$line" \
        "$caller"

    _err_report "$report"
}

# ==============================================================================
# Fatal Error
# ==============================================================================

fatal() {
    local message="$1"

    error_report \
        "Fatal error" \
        "$message" \
        "${BASH_SOURCE[1]:-unknown}" \
        "${BASH_LINENO[0]:-unknown}" \
        "${FUNCNAME[1]:-main}"

    declare -g FATAL_REPORTED=1

    return 1
}