#!/usr/bin/env bash

# ==============================================================================
# Template Module Bootstrap
# ==============================================================================
# modules/template/bootstrap_template_copy.sh
#
# Prepares the template module.
#
# Responsibilities:
#   - Establish module paths
#   - Load module components
#
# Constraints:
#   - Sourced by module_loader.sh, which then calls bootstrap_template.
#   - Definitions only at top level; all work happens in bootstrap_template.
#   - Components are loaded, never executed.
#   - Inherits PROJECT_DIR, shell options and traps from the orchestrator.
# ==============================================================================

# ==============================================================================
# Module Environment
# ==============================================================================

readonly TEMPLATE_COPY_PATH="$PROJECT_DIR/modules/template_copy"

# ==============================================================================
# Module Components
# ==============================================================================

readonly -a TEMPLATE_COPY_COMPONENTS=(
    "template_copy_run.sh"
)

# ==============================================================================
# Load Module Components
# ==============================================================================

load_template_copy_components() {
    load_components "$TEMPLATE_COPY_PATH" "$@"

    msg "Template copy module components loaded."
}

# ==============================================================================
# Bootstrap
# ==============================================================================

bootstrap_template_copy() {
    load_template_copy_components "${TEMPLATE_COPY_COMPONENTS[@]}"
    msg "Template copy module bootstrap completed."
}