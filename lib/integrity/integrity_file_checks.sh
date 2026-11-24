#!/usr/bin/env bash

# ==============================================================================
# Integrity File Checks
# ==============================================================================
# lib/integrity/integrity_file_checks.sh
#
# Provides file validation functions.
#
# Responsibilities:
#   - Verify that required files exist
#   - Verify that required files are readable
#   - Validate Bash syntax
#
# Dependencies:
#   - err_missing_file()
#   - err_unreadable_file()
#   - fatal()
#
# Constraints:
#   - Sourced library: definitions only.
#   - Does not source or execute files.
#   - Does not create, modify or remove files.
# ==============================================================================

# ==============================================================================
# Check File
# ==============================================================================

integrity_check_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        err_missing_file "$file"
        return 1
    fi

    if [[ ! -r "$file" ]]; then
        err_unreadable_file "$file"
        return 1
    fi

    local syntax_error
    if ! syntax_error=$(bash -n "$file" 2>&1); then
        fatal "Syntax validation failed: $file: $syntax_error"
        return 1
    fi
}
