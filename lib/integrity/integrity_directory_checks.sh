#!/usr/bin/env bash

# ==============================================================================
# Integrity Directory Checks
# ==============================================================================
# lib/integrity/integrity_directory_checks.sh
#
# Provides directory validation functions.
#
# Responsibilities:
#   - Verify that required directories exist
#
# Dependencies:
#   - err_missing_directory()
#
# Constraints:
#   - Sourced library: definitions only.
#   - Does not create, modify or remove directories.
#   - Does not load components.
# ==============================================================================

# ==============================================================================
# Check Directory
# ==============================================================================

integrity_check_directory() {
    local directory="$1"

    [[ -d "$directory" ]] ||
        err_missing_directory "$directory"
}