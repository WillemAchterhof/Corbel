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
#   - integrity_check_directory()
#   - integrity_check_file()
#   - fatal()
#   - msg()
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
    [[ $# -ge 1 ]] || fatal "load_components requires a directory argument"

    local directory="$1"
    shift

    local component
    local component_path
    local component_group="${directory##*/}"

    component_group="${component_group^}"

    integrity_check_directory "$directory"

    # Validate every component before sourcing any of them.
    for component in "$@"; do
        component_path="$directory/$component"
        integrity_check_file "$component_path"
    done

    # Source validated components.
    for component in "$@"; do
        component_path="$directory/$component"

        # shellcheck source=/dev/null
        source "$component_path"
    done

    msg "Loaded: $component_group components"
}
