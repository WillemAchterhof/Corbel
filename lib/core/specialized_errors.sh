#!/usr/bin/env bash

# ==============================================================================
# Specialized Errors
# ==============================================================================
# lib/core/specialized_errors.sh
#
# Responsibilities:
#   - Handle deliberate validation errors
#   - Provide descriptive messages for missing resources
#   - Delegate termination to the ERR trap
#
# Constraints:
#   - Defines specialized error functions only.
#   - Never exits directly.
# ==============================================================================

# ==============================================================================
# Missing Directory
# ==============================================================================

err_missing_directory() {
    local directory="$1"

    fatal \
        "Module directory missing: ${directory#"$PROJECT_DIR"/}"
}

# ==============================================================================
# Missing File
# ==============================================================================

err_missing_file() {
    local file="$1"

    fatal \
        "Required file missing: ${file#"$PROJECT_DIR"/}"
}

# ==============================================================================
# Missing Function
# ==============================================================================

err_missing_function() {
    local function_name="$1"
    local source_file="$2"

    fatal \
        "Entry function missing (${function_name}) in ${source_file#"$PROJECT_DIR"/}"
}
