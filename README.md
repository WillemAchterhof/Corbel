# Shell Framework

A reusable Bash framework for building installers, deployment scripts, and
ordered multi-stage tooling. Born as the Corbel installer skeleton, now
extracted as a project-agnostic foundation.

The framework gives you a layered orchestrator that loads validated modules
from a declarative pipeline, with a two-path error model that makes every
failure loud, located, and logged.

---

## Quick start

```bash
git clone <repo> myproject
cd myproject

# rename to taste — only the project name and module payload are coupled:
#   * pipeline contents (orchestrator/corbel-pipeline.sh → PIPELINE_MODULES)
#   * the modules/ directory contents
#   * project name in comments / log filename

./orchestrator/launch-orchestrator.sh
```

---

## Directory layout

```
.
├── Corbel.log                  # created at startup (one per run)
├── orchestrator/
│   ├── launch-orchestrator.sh     # entry point: shell regime, traps, wiring
│   ├── corbel-pipeline.sh      # module sequence + load/run loops
│   └── module-loader.sh           # loads one module (locate/validate/source)
├── lib/
│   ├── launch-initialize.sh       # bootstrap: raw loading primitives
│   ├── initialize-logging.sh      # msg / success / warn / fatal / log_only
│   └── initialize-errorhandling.sh# trap_err: the ERR trap handler
└── modules/
    ├── template/                  # canonical copy-and-go module template
    │   └── launch-template.sh
    └── test/                      # sample module
        └── launch-test.sh
```

Each module lives in `modules/<name>/launch-<name>.sh` and exposes exactly one
public function: `run_<name>`.

---

## Architecture

### Layering

```
entry point  →  lib bootstrap  →  orchestrator components  →  modules
```

1. **Entry point** (`launch-orchestrator.sh`) — owns the shell regime
   (`set -Eeuo pipefail`), installs traps, wires everything, runs the
   pipeline. It knows exactly two orchestrator components and nothing about
   modules.
2. **Raw layer** (`launch-initialize.sh`) — hosts the shared loading
   primitives (`lib_check_file`, `lib_source_file`, `lib_load_files`),
   creates the log file, and loads the logging/error-handling libs. Sources
   nothing; may rely only on raw `printf`/`return` — plus `fatal` once it
   has been defined.
3. **Orchestrator layer** (`corbel-pipeline.sh`, `module-loader.sh`) —
   the pipeline declares the module sequence and controls progression; the
   loader locates, validates, and sources a single module.
4. **Modules** — self-contained units. Definitions only at source time; all
   work happens inside `run_<name>`.

### Ownership rule

> Whoever consumes a thing declares it; the layer above only wires entry
> points.

Concretely:

- The **pipeline** declares `PIPELINE_MODULES` — not the launcher, not a
  config file.
- The **loader** performs the collision check — a second module defining
  `run_<name>` is rejected at load time, not silently overwriting the first.
- The **entry point** names exactly two orchestrator components and the
  bootstrap library. Nothing else.
- Modules prefix their helper functions with `<name>_` to stay out of each
  other's namespace.

### Error model — the core contract

There are exactly two failure paths, and each has one job:

| Failure type | Path | Behavior |
|---|---|---|
| **Anticipated** (missing file, bad name, syntax error, collision) | `fatal` | One `[FATAL]` message, logged to screen and file, `exit 1`. Works in every context because `exit` ignores `-e` suppression. |
| **Unanticipated** (typos, failed commands, unexpected exits) | `errexit` + ERR trap | `trap_err` reports module, file, line, caller, command, and exit code (with `127 → not found`, `126 → not executable` decoding), preserves the original exit code, and exits. |

**The rule that keeps this model intact:**

> In Bash, `||` is a decision operator, not error handling. Calling a
> function under `||` suspends `set -e` **and the ERR trap for the entire
> call tree**, not just for that call. A guard like `run_pipeline || return 1`
> disables the safety net for every module it runs.

Therefore:

- **Call action functions bare.** No `|| return 1` guards on actions whose
  internals deserve protection.
- **Use `||` only for decisions**, where the right side handles the outcome
  — `[[ -f "$file" ]] || fatal "..."`, `declare -F "$entry" || fatal "..."`,
  `source "$file" || lib_fail "..."`.
- **Modules fail loudly.** A failing check stops the installer via the trap;
  reserve `||` inside modules for genuine recoverable decisions.

### Validation-before-execution

The framework never runs half a pipeline by accident:

- `lib_load_files` validates (`-f`, `-r`, `bash -n`) **every** file before
  sourcing **any**.
- `load_pipeline_modules` loads and validates every module before the first
  one runs.
- `run_pipeline_modules` re-verifies all entry functions exist before
  executing the sequence.
- Module names are checked against `^[a-zA-Z0-9_-]+$` before they touch the
  filesystem — path traversal (`../../etc`) is rejected outright.
- Entry-function collision is checked **before** sourcing and existence
  re-checked **after** — a module file that parses but doesn't deliver its
  contract never enters the pipeline.

### Logging

All output flows through the logging lib — no bare `echo`:

| Function | Stream | Log file |
|---|---|---|
| `msg` / `success` | stdout | yes |
| `warn` / `fatal` | stderr | yes |
| `log_only` | — | only |

The log file is truncated at startup. Output conventions: every user-facing
message starts with a capital letter.

### `AG_CURRENT_MODULE` protocol

`load_pipeline_modules` and `run_pipeline_modules` each set
`AG_CURRENT_MODULE` before processing a module and clear it after their
loop. `trap_err` reads it, so error reports name the current module during
**both** the load and the run phase.

---

## Writing a module

Copy `modules/template/` to `modules/<name>/` and rename the launcher to
`launch-<name>.sh`. Follow the conventions:

```bash
#!/usr/bin/env bash

# ==============================================================================
#  <Project> <Title> Module
# ==============================================================================
#  modules/<name>/launch-<name>.sh
#
#  <One-line description.>
#
#  Responsibilities:
#    - <what it does>
#
#  Constraints:
#    - Definitions only at top level; all work happens in run_<name>.
#    - Helper functions are prefixed with <name>_ to avoid name clashes.
# ==============================================================================

<name>_check() {
    msg "Checking <something>..."
    # Failures here stop the installer via errexit + ERR trap.
}

run_<name>() {
    <name>_check

    success "<Name> module executed successfully."
}
```

Rules that the framework enforces or assumes:

1. Exactly one public function: `run_<name>` — a collision anywhere else in
   the pipeline is a fatal load error.
2. No top-level side effects: sourcing the module must only define functions.
3. Helpers prefixed with `<name>_`.
4. Fail loudly: don't swallow errors; let the trap report them with context.
5. Use only the logging lib for output.

Then register it in the pipeline:

```bash
readonly PIPELINE_MODULES=(
    "preflight"
    "<name>"
)
```

That's the whole integration surface — one array entry.

---

## Deriving a new project

The framework is deliberately name-agnostic except for three touch points:

1. **`PIPELINE_MODULES`** — empty it and fill it with your project's
   modules.
2. **`modules/`** — delete `test/` and `template/` when you add real ones
   (keep `template/` around during development; a heartbeat module is a
   useful sanity check).
3. **Project name** — in comments and the log filename. To eliminate even
   the log rename, derive it from the directory:

   ```bash
   LOG_FILE="$PROJECT_DIR/$(basename "$PROJECT_DIR").log"
   ```

Keep every other filename as-is across all projects using the framework —
`launch-orchestrator.sh`, `module-loader.sh`, `corbel-pipeline.sh` — so
recognition transfers between projects.

The pipeline file is the only orchestrator file whose name leaks the old
project ("corbel"); rename it only if the cognitive itch outweighs
cross-project muscle memory, and update the single reference in
`orch_load_components` if you do.

---

## Verification

Before trusting a change, run both gates:

```bash
# Gate 1: static
shellcheck lib/*.sh orchestrator/*.sh modules/*/*.sh

# Gate 2: behavioral — corrupt a module on purpose
echo "this is not bash" >> modules/test/launch-test.sh
./orchestrator/launch-orchestrator.sh
# Expect: ONE [FATAL] error report naming the module, clean exit,
# and NO pipeline progression past the failure.
```

If the corruption produces two messages (a raw line plus a trap report),
the `lib_fail` → `fatal` delegation has regressed. If the pipeline
continues after a failure, something reintroduced a `||` guard on an
action — re-read the error model above.

---

## Conventions recap

- `set -Eeuo pipepipefail` — the ERR trap inherits into every function.
- Bare calls for actions; `||` only where the right side handles the
  outcome.
- `bash -n` gates every sourced file; `bash -n` validates syntax, never
  names — a typo'd function name is invisible until runtime.
- One loading path in the codebase (`lib_*` primitives); no duplicated
  validate/source logic anywhere else.
- Headers tell the truth: Responsibilities and Constraints sections
  describe what the file *actually does*. When behavior changes, the
  header changes with it.
- Captalized log strings; all output through the logging lib.
