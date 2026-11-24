#!/usr/bin/env bash

# ==============================================================================
# Integrity Function Checks
# ==============================================================================
# lib/integrity/integrity_function_checks.sh
#
# Provides function validation and integrity checks.
#
# Responsibilities:
#   - Verify that expected functions exist
#   - Snapshot existing function definitions
#   - Detect changes to previously defined functions
#   - Detect removal of previously defined functions.
#
# Dependencies:
#   - err_missing_function()
#   - fatal()
#
# Constraints:
#   - Sourced library: definitions only.
#   - Does not execute module functions.
#   - Does not load or source files.
# ==============================================================================

# ==============================================================================
# Check Function
# ==============================================================================

integrity_check_function() {
    local function_name="$1"
    local source_file="$2"

    declare -F "$function_name" >/dev/null ||
        err_missing_function "$function_name" "$source_file"
}

# ==============================================================================
# Snapshot Functions
# ==============================================================================

integrity_snapshot_functions() {
    local -n snapshot_ref="$1"
    local function_name

    snapshot_ref=()

    while IFS= read -r function_name; do
        snapshot_ref["$function_name"]="$(declare -f "$function_name")"
    done < <(compgen -A function)
}

# ==============================================================================
# Check Existing Functions
# ==============================================================================

integrity_check_functions_unchanged() {
    local -n before_ref="$1"
    local label="$2"

    local function_name

    for function_name in "${!before_ref[@]}"; do
        if ! declare -F "$function_name" >/dev/null; then
            fatal "$label removed existing function: $function_name"
        fi

        if [[ "$(declare -f "$function_name")" != "${before_ref[$function_name]}" ]]; then
            fatal "$label redefined existing function: $function_name"
        fi
    done
}