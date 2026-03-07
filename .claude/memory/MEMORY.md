# Code Monkey — Session Memory

## Project
Godot 4.5 turn-based game. Main scene: `scenes/game_ui.tscn`. See CLAUDE.md for full overview.

## Confirmed Patterns

### Theme type variations (Godot 4.5)
`TypeName/font_sizes/font_size = N` in `.tres` files works for custom type names.
Set `theme_type_variation = "TypeName"` on Label nodes in the scene. Verified via diagnostic.
All sizes live in `themes/main_theme.tres` — never use `add_theme_font_size_override` in code.

Defined variations:
- `TopBarLabel` → 32px
- `TaskTitleLabel` → 28px
- `MetricLabel` → 24px
- `EndGameTitle` → 48px
- Button → 22px (built-in type)
- Label default → 20px

### Diagnostic script pattern
To verify a resource's values without running the full game:
```gdscript
# scenes/font_test.gd
extends SceneTree
func _init():
    var res = load("res://path/to/resource.tres")
    print(res.some_property)
    quit()
```
Run with: `godot --headless --script scenes/font_test.gd 2>&1`

### /look calibration
The game window is 480×854 — a small portrait window on desktop. Text that is correctly sized (e.g. 32px) will look small in screenshots. Trust game coordinates, not visual impression from /look.

### Screen Recording permission
`screencapture` requires Screen Recording permission granted to the Terminal app (not Claude/Bash directly). System Settings → Privacy & Security → Screen Recording.

## Workflow Preferences

### Commit granularity
One logical change per commit with a clear subject. Plan changes, tooling, and implementation all get separate commits even within the same step.

### PR granularity
PRs at step level — sub-steps (5a/5b/5c) are commits within one PR, not separate PRs.

### Build order
See the full UI hardcoded first. Wire signals only when there's a button to trigger them. Don't wire UI components until something can cause them to change.

### Incremental UI wiring
One UI component per commit when wiring. Makes it easy to `/look` and confirm exactly one thing changed.

### Defer mechanics until meaningful
Don't implement a mechanic until it has something to interact with. Payday deferred to HUSTLE step where money first matters.

### GUT testing principle
Use GUT for logic that has no UI or scene tree dependency and could silently break when balance values change. Pure functions qualify automatically but aren't the only criterion — isolated game logic like `_check_game_state()` or detection rolls also qualify if they're self-contained.

Test files live in `test/unit/` (not `tests/` as the plan doc says).

GUT pattern for autoload nodes: `node = AutoloadName.duplicate()`, `add_child_autofree(node)`, then set state directly.

GUT pattern for signal emission tests — override balance key, set state, watch, call method, assert:
```gdscript
func test_some_condition_emits_signal():
    game_manager.balance["some_threshold"] = 10  # override to low value
    game_manager.balance["other_needed_key"] = 5000  # set all keys _check_game_state reads
    game_manager.some_var = 10
    watch_signals(game_manager)
    game_manager._check_game_state()
    assert_signal_emitted_with_parameters(game_manager, "game_over", ["reason"])
```
Note: `before_each` balance dict only includes keys the existing tests need — add any extra keys inline in the test that requires them.

### TDD — test first for logic
For any logic that qualifies for GUT: write the failing test first, run `make test` to confirm it fails, then implement. Applies to every `calculate_*` function, every flag/state check, every signal-emitting condition. UI changes use `/check` + `/look` after the fact.

### Named constants vs balance.json
Balance values (tunable via playtesting) → `data/balance.json`.
Structural constants (not tunable, just named for clarity) → `const` in the owning autoload.
Example: `TASK_MAX_PROGRESS = 100.0` lives in `task_manager.gd`, referenced from `game_manager.gd` and `game_ui.gd`. Don't introduce bare `100.0` magic numbers even for "obvious" scales.

### Worktree pattern
When two sessions share the same folder, create a worktree: `git worktree add ../game-code-monkey-stepN branch-name`.
Symlink addons: `ln -s /path/to/main/addons /path/to/worktree/addons`.
Run `godot --headless --import` once in the worktree to register GUT classes.
Remove after merge: `git worktree remove --force ../worktree-dir`.
Stray `.uid` files from the worktree may leak into main dir — delete before `git pull`.

### Tooling
- `make help` — list all targets (Makefile is source of truth; ## comments drive output)
- `make install` — install GUT + gdtoolkit (calls install-gut then pip)
- `make lint` — run gdlint (no Godot needed)
- `make check` — headless error check
- `make test` — run GUT suite
- `make install-gut` — install GUT only, via `scripts/install_gut.sh`
- `make worktree-init WORKTREE=<path>` — symlink addons/ into a worktree so `make test` works
- Godot binary: `/home/bokchoi/Applications/Godot_v4.5.1-stable_linux.x86_64` (Linux), configured in `config.mk`
- `addons/` is gitignored — install GUT via `make install-gut`
- After installing GUT on a fresh checkout, run `godot --headless --import` once to register class names
- **NEVER call godot directly** — always use `make test`, `make check`, `make simulate`. The `/test`, `/check`, `/simulate` skills do this correctly (use `make …`).

### Current build state (as of 2026-03-07)
Task-pool plan (`docs/plans/task-pool.md`) steps done:
- ✅ 1 — `data/tasks.json` restructured into `{tier1, tier2}`
- ✅ 2 — `tasks_shipped` counter in GameManager
- ✅ 3 — `total_bugs_added` counter in GameManager
- ✅ 4 — `sloppy_ships` counter in GameManager
- ✅ 5 — `tasks_on_time` / `tasks_late` counters in GameManager
- ✅ 6 — tier-aware sequence logic in TaskManager (`unlock_tier2(day)`)
- ⬜ 7 — Day 30 review dialog (reads counters, fires at day 30, calls `TaskManager.unlock_tier2()`)
- ⬜ 8 — `balance.json` `win_goal: 10000`

### Git / PR workflow
- Always create a feature branch before starting work — never commit directly to main.
  main has branch protection; direct pushes bypass it but skip PR review.
- Branch: `git checkout -b feat/short-description` or `fix/short-description`
- Raise PR with `gh pr create` once work is ready.

### GUT process hangs after finishing
`godot --headless -s addons/gut/gut_cmdln.gd` doesn't self-exit. All output arrives, but the process keeps running — kill it with TaskStop after reading results.

### Linter var ordering
gdformat reorders vars: public before private. Don't fight it — treat linter reformats as intentional.

### Godot / GUT version pairing
GUT versions track Godot minor versions — they must be kept in sync.
- Godot **4.5** → GUT **9.5.0** (pinned in `scripts/install_gut.sh`)
- Updating Godot means updating the GUT pin too.

### Squashing debug noise
Before merging a PR, squash iterative fix/debug commits into the commit that introduced the thing being fixed. Only meaningful logical steps should survive as separate commits.
