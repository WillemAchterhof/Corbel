#!/usr/bin/env bash

# ==============================================================================
#  Project Error Handling
# ==============================================================================
#  lib/core/errorhandling.sh
#
#  ERR trap handler — reports the failing command, file, and caller.
#
#  Constraints:
#    - Defines trap_err; does NOT install it. The entry point installs traps.
#    - Paths are reported relative to PROJECT_DIR, so files in different
#      domains remain distinguishable even when names collide.
# ==============================================================================

trap_err() {
    trap - ERR

    local exit_code=$1
    local failing_command=${2:-unknown}
    local line=${3:-unknown}
    local call_line=${4:-unknown}
    local file="${BASH_SOURCE[1]:-$PROJECT_DIR/unknown}"
    local caller_file="${BASH_SOURCE[2]:-$PROJECT_DIR/unknown}"
    local caller_func="${FUNCNAME[2]:-main}"

    local error_type=""

    if (( exit_code == 127 )); then
        error_type="'${failing_command%% *}' not found"
    elif (( exit_code == 126 )); then
        error_type="'${failing_command%% *}' not executable"
    fi

    local message="[FATAL] Error
    File    : ${file#"$PROJECT_DIR/"}:${line}
    Command : ${error_type:-${failing_command}}
    Caller  : ${caller_file#"$PROJECT_DIR/"}:${call_line} (${caller_func})
    Exit    : ${exit_code}"

    { printf '%s\n' "$message" >> "$LOG_FILE"; } 2>/dev/null || true
    printf '%s\n' "$message" >&2

    exit "$exit_code"
}
