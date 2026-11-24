#!/usr/bin/env bash

# ==============================================================================
# Project Pipeline
# ==============================================================================
# orchestrator/project_pipeline.sh
#
# Defines the load order of the project modules.
#
# Dependencies:
#   - load_module()    (lib/integrity/integrity_module_loader.sh)
#
# Constraints:
#   - Loads and bootstraps modules only.
#   - Never executes module run functions.
#   - All modules load before any module executes.
#   - Execution order lives in project_orchestrator.sh.
#   - Call only in errexit-active context (not inside if, ||, or !).
# ==============================================================================

# ==============================================================================
# Pipeline
# ==============================================================================

readonly -a PIPELINE_MODULES=(
    "template"
    # ... module load order grows here
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