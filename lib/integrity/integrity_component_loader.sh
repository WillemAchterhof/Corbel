#!/usr/bin/env bash

# ==============================================================================
# Integrity Component Loader
# ==============================================================================
# lib/integrity/integrity_component_loader.sh
#
# Provides generic loading of project component files.
#
# Responsibilities:
#   - Validate component directories
#   - Validate component files
#   - Validate Bash syntax before loading
#   - Source validated component files
#
# Dependencies:
#   - err_missing_directory()
#   - err_missing_file()
#   - fatal()
#
# Constraints:
#   - Sourced library: definitions only.
#   - Validates all requested files before sourcing any of them.
#   - Does not execute functions defined by components.
# ==============================================================================

# ==============================================================================
# Load Components
# ==============================================================================

load_components() {
    local directory="$1"
    shift

    local component

    [[ -d "$directory" ]] ||
        err_missing_directory "$directory"

    for component in "$@"; do
        local component_path="$directory/$component"

        [[ -f "$component_path" && -r "$component_path" ]] ||
            err_missing_file "$component_path"

        bash -n "$component_path" ||
            fatal "Failed loading component: $component_path"
    done

    for component in "$@"; do
        local component_path="$directory/$component"

        # shellcheck source=/dev/null
        source "$component_path"
    done

    success "Loaded: ${directory##*/} components"
}