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
#   - msg()
#   - fatal()
#
# Constraints:
#   - Executes only; modules are loaded by project_pipeline.sh.
#   - Call only in errexit-active context (not inside if, ||, or !).
#   - Module functions report their own successful completion.
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

    # Verify every execution function before running any of them.
    for step in "${ORCHESTRATOR_STEPS[@]}"; do
        declare -F "$step" >/dev/null ||
            fatal "Orchestrator step missing: $step"
    done

    for step in "${ORCHESTRATOR_STEPS[@]}"; do
        AG_CURRENT_MODULE="${step#run_}"
        msg "Running: $step"
        "$step"
    done

    unset AG_CURRENT_MODULE
}
