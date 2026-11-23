#!/usr/bin/env bash

# ==============================================================================
# Project Core — Component Loader
# ==============================================================================
# lib/core/component_loader.sh
#
# Provides the shared function for loading project components.
#
# Responsibilities:
#   - Verify each component file exists, is readable and has valid syntax
#   - Source the component files into the current shell
#
# Dependencies:
#   - core_check_file()      (lib/core/bootstrap_core.sh)
#   - core_source_file()     (lib/core/bootstrap_core.sh)
#   - err_missing_file()     (lib/core/specialized_errors.sh)
#
# Usage:
#   load_components "$COMPONENT_PATH" "${COMPONENTS[@]}"
#
# Constraints:
#   - Sources files only after all files pass validation.
#   - Prints nothing on success; the caller decides what to log.
#   - Call only in errexit-active context (not inside if, ||, or !).
# ==============================================================================

# ==============================================================================
# Load Components
# ==============================================================================

load_components() {
    local directory="$1"
    shift

    local component

    for component in "$@"; do
        [[ -f "$directory/$component" ]] ||
            err_missing_file "$directory/$component"

        core_check_file "$directory/$component"
    done

    for component in "$@"; do
        # shellcheck source=/dev/null
        source "$directory/$component"
    done
}