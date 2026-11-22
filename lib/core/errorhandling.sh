
#!/usr/bin/env bash

# ==============================================================================
# Project Error Handling
# ==============================================================================
# lib/core/errorhandling.sh
#
# Responsibilities:
#   - Handle unexpected command failures through trap_err
#   - Report specialized validation errors
#   - Provide consistent error formatting
#   - Log fatal errors
#
# Constraints:
#   - Defines functions only; does not install traps.
#   - All fatal errors terminate execution.
# ==============================================================================


# ==============================================================================
# Internal Error Reporter
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
    report= printf '%b\n' "[FATAL] Error\t: ${title}
  \t${detail_label}\t: ${detail}
  \tCaller\t: ${relative_caller}:${caller_line} (${caller_func})"

    printf '%s\n' "$report" >&2
    { printf '%s\n' "$report" >> "$LOG_FILE"; } 2>/dev/null || true

    exit "$exit_code"
}


# ==============================================================================
# Specialized Errors
# ==============================================================================

err_missing_directory() {
    local directory="$1"

    _err_die \
        "Module directory missing." \
        "Folder" \
        "${directory#"$PROJECT_DIR"/}" \
        "${BASH_SOURCE[1]}" \
        "${BASH_LINENO[0]}" \
        "${FUNCNAME[1]}"
}


err_missing_file() {
    local file="$1"
    local caller_file="$2"
    local caller_line="$3"
    local caller_func="$4"

    _err_die \
        "Required file missing." \
        "File" \
        "${file#"$PROJECT_DIR"/}" \
        "$caller_file" \
        "$caller_line" \
        "$caller_func"
}


err_missing_function() {
    local function_name="$1"
    local source_file="$2"
    local module_name="${function_name#run_}"

    _err_die \
        "${module_name} entry function missing (${function_name})." \
        "File" \
        "${source_file#"$PROJECT_DIR"/}" \
        "${BASH_SOURCE[1]}" \
        "${BASH_LINENO[0]}" \
        "${FUNCNAME[1]}"
}

# ==============================================================================
# Unexpected Command Errors
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

    file="${file#"$PROJECT_DIR"/}"
    caller_file="${caller_file#"$PROJECT_DIR"/}"

    local title="Command failed."

    if (( exit_code == 127 )); then
        title="Command not found."
    elif (( exit_code == 126 )); then
        title="Command not executable."
    fi

    local report
    report= printf '%b\n' "[FATAL] Error\t: ${title}
  \tCommand\t: ${failing_command}
  \tFile\t: ${file}:${line}
  \tCaller\t: ${caller_file}:${call_line} (${caller_func})"

    printf '%s\n' "$report" >&2
    { printf '%s\n' "$report" >> "$LOG_FILE"; } 2>/dev/null || true

    exit "$exit_code"
}