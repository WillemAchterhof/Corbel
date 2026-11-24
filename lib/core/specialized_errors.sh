#!/usr/bin/env bash

# ==============================================================================
# Specialized Errors
# ==============================================================================
# lib/core/specialized_errors.sh
#
# Provides descriptive error functions for expected validation failures.
#
# Responsibilities:
#   - Report missing directories
#   - Report missing files
#   - Report missing functions
#   - Provide meaningful resource and function context
#
# Constraints:
#   - Sourced library: definitions only.
#   - Uses fatal() for centralized error reporting.
#   - Does not install traps.
#   - Never exits directly.
# ==============================================================================

# ==============================================================================
# Missing Directory
# ==============================================================================

err_missing_directory() {
    local directory="$1"

    fatal \
        "Required directory missing: ${directory#"$PROJECT_DIR"/}"
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
        "Required function missing: $function_name (expected in ${source_file#"$PROJECT_DIR"/})"
}