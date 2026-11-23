#!/usr/bin/env bash

# ==============================================================================
# Shared Error Handling
# ==============================================================================
# lib/core/error_handling.sh
#
# Responsibilities:
#   - Provide consistent fatal error handling
#   - Report deliberate fatal errors
#   - Preserve ERR-trap flow
#
# Constraints:
#   - Defines internal error helpers only.
#   - Does not install traps.
#   - Does not define specialized error messages.
#   - Never exits directly.
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
# Fatal Error
# ==============================================================================

fatal() {
    local message="$1"

    _err_report "[FATAL] $message"
    declare -g FATAL_REPORTED=1

    return 1
}
