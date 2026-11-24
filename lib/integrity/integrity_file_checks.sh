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

    [[ -f "$file" && -r "$file" ]] ||
        err_missing_file "$file"

    bash -n "$file" ||
        fatal "Syntax validation failed: $file"
}