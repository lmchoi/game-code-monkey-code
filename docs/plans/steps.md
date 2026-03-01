# Build Steps

Each step is a self-contained unit of work with clear acceptance criteria.
Run `/check` before committing. Eyeball the game after every visual change.

---

## Step 1 — Project Skeleton

**Goal:** Game launches without errors. Nothing visible yet beyond an empty window.

**Acceptance Criteria:**
- [ ] Window opens in portrait orientation, 480×854
- [ ] Default scene is `scenes/game_ui.tscn`
- [ ] `autoloads/game_manager.gd` exists and is registered — stub only (`extends Node`)
- [ ] `autoloads/task_manager.gd` exists and is registered — stub only (`extends Node`)
- [ ] `/check` passes with no errors or warnings

**Notes:**
- No UI, no logic — just the skeleton
- Portrait size 480×854 is the working resolution (tune later if needed)
