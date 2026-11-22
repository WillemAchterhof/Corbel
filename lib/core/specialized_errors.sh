#!/usr/bin/env bash

# ==============================================================================
# Specialized Errors
# ==============================================================================
# lib/core/specialized_errors.sh
#
# Responsibilities:
#   - Handle deliberate validation errors
#   - Provide descriptive messages for missing resources
#   - Report the original caller location
#
# Constraints:
#   - Defines specialized error functions only.
#   - Uses the shared error reporter from error_handling.sh.
#   - All fatal errors terminate execution.
# ==============================================================================


# ==============================================================================
# Missing Directory
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


# ==============================================================================
# Missing File
# ==============================================================================

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


# ==============================================================================
# Missing Function
# ==============================================================================

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