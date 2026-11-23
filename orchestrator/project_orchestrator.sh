#!/usr/bin/env bash

# ==============================================================================
# Project Orchestrator
# ==============================================================================
# orchestrator/project_orchestrator.sh
#
# Executes the loaded module functions in the required order.
#
# Responsibilities:
#   - Define the execution order of module functions
#   - Verify every function exists before running any of them
#   - Call the functions one by one
#
# Dependencies:
#   - msg(), success(), fatal()
#
# Constraints:
#   - Executes only; modules are loaded by project_pipeline.sh.
#   - Call only in errexit-active context (not inside if, ||, or !).
# ==============================================================================

# ==============================================================================
# Execution Order
# ==============================================================================

readonly -a ORCHESTRATOR_STEPS=(
    "run_template"
    # ... execution order grows here
)

# ==============================================================================
# Run Orchestrator
# ==============================================================================

run_orchestrator() {
    local step

    for step in "${ORCHESTRATOR_STEPS[@]}"; do
        declare -F "$step" >/dev/null ||
            fatal "Orchestrator step missing: $step"
    done

    for step in "${ORCHESTRATOR_STEPS[@]}"; do
        msg "Running: $step"

        "$step"

        success "Finished: $step"
    done
}