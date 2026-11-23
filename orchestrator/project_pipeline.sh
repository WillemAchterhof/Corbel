#!/usr/bin/env bash

# ==============================================================================
# Project Pipeline
# ==============================================================================
# orchestrator/project_pipeline.sh
#
# Defines the execution sequence of the installer.
#
# Responsibilities:
#   - Define the execution order of installer modules
#   - Control progression through the installation stages
# ==============================================================================

# ==============================================================================
# Pipeline
# ==============================================================================

readonly -a PIPELINE_MODULES=(
    "template"
    # ... install sequence grows here
)

# ==============================================================================
# Load Pipeline Modules
# ==============================================================================

load_pipeline_modules() {
    local module_name

    for module_name in "${PIPELINE_MODULES[@]}"; do
        load_module "$module_name"
    done
}

# ==============================================================================
# Run Pipeline Modules
# ==============================================================================

run_pipeline_modules() {
    local module_name

    for module_name in "${PIPELINE_MODULES[@]}"; do
        declare -F "run_${module_name}" >/dev/null ||
            fatal "Module entry function missing: run_${module_name}"
    done

    for module_name in "${PIPELINE_MODULES[@]}"; do
        msg "Running module: $module_name"

        "run_${module_name}"

        success "Finished module: $module_name"
    done
}

# ==============================================================================
# Run Pipeline
# ==============================================================================

run_pipeline() {
    load_pipeline_modules
    run_pipeline_modules
}
