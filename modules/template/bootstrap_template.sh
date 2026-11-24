#!/usr/bin/env bash

# ==============================================================================
# Template Module Bootstrap
# ==============================================================================
# modules/template/bootstrap_template.sh
#
# Prepares the template module.
#
# Responsibilities:
#   - Establish module paths
#   - Load module components
#
# Constraints:
#   - modules/template/template_run.sh
#   - Definitions only at top level; all work happens in bootstrap_template.
#   - Components are loaded, never executed.
#   - Inherits PROJECT_DIR, shell options and traps from the orchestrator.
# ==============================================================================

# ==============================================================================
# Module Environment
# ==============================================================================

readonly TEMPLATE_PATH="$PROJECT_DIR/modules/template"

# ==============================================================================
# Module Components
# ==============================================================================

readonly -a TEMPLATE_COMPONENTS=(
    "template_run.sh"
)

# ==============================================================================
# Load Module Components
# ==============================================================================

load_template_components() {
    load_components "$TEMPLATE_PATH" "$@"

    msg "Template module components loaded."
}

# ==============================================================================
# Bootstrap
# ==============================================================================

bootstrap_template() {
    load_template_components "${TEMPLATE_COMPONENTS[@]}"
    msg "Template module bootstrap completed."
}