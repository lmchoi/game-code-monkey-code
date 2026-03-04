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

---

## Step 2 — Top Bar (hardcoded)

**Goal:** The top bar renders correctly with static text. No logic, no signals.

**Layout:**
```
┌──────────────────────────────────────────┐
│  Day 1                  💰 $0 / $5,000   │
└──────────────────────────────────────────┘
```

**What to build:**

1. Change `game_ui.tscn` root node from `Node2D` → `Control` (full-rect anchor)
2. Set `theme = themes/main_theme.tres` on the root Control
3. Add a `PanelContainer` pinned to the top of the screen, full width
4. Inside it: `HBoxContainer` with two `Label` nodes
   - Left label: `"Day 1"` — left-aligned, `theme_type_variation = "TopBarLabel"`
   - Right label: `"💰 $0 / $5,000"` — right-aligned (size flag: Expand + Fill), `theme_type_variation = "TopBarLabel"`

**Font sizes — use `theme_type_variation`, never inline overrides:**
| Variation | Size | Used for |
|-----------|------|----------|
| `TopBarLabel` | 32px | Day counter, money display |
| `TaskTitleLabel` | 28px | Task card heading |
| `MetricLabel` | 24px | Progress %, deadline |
| `EndGameTitle` | 48px | Recap screen heading |
| *(default Label)* | 20px | Everything else |
| *(Button)* | 22px | Action buttons |

All sizes live in `themes/main_theme.tres` — the single source of truth. Never use `add_theme_font_size_override`.

**Files touched:**
- `scenes/game_ui.tscn`

**Acceptance Criteria:**
- [ ] Top bar is visible at the top of the screen
- [ ] "Day 1" appears on the left, "💰 $0 / $5,000" on the right
- [ ] Both labels are 32px (via `TopBarLabel` variation — verify in editor)
- [ ] Bar spans full width, doesn't overflow
- [ ] `/check` passes with no errors
- [ ] `/look` confirms layout looks right

**Notes:**
- Hardcoded strings only — wiring to GameManager happens in Step 5 (WORK button)
- Dark background on the top bar is fine but not required at this step — focus on layout

---

## Step 3 — Task Card (hardcoded)

**Goal:** Full game layout visible with hardcoded task data. All three buttons present but disabled.

**Layout to build:**
```
[TopBar]          ← already exists

[TaskCard]
  Build a blockchain todo app
  🍝  ·  Due: Day 6
  ████████████░░░░░░░░  85%
  [ 🟢  SHIP IT ]

[ WORK ]    [ HUSTLE ]
```

**What to build:**

1. `TaskCard` — `PanelContainer` that fills the middle of the screen:
   - `TaskTitleLabel` (Label, `TaskTitleLabel` variation) — `"Build a blockchain todo app"`
   - Meta row (`HBoxContainer`): complexity label `"🍝"` + deadline label `"· Due: Day 6"` (MetricLabel)
   - `ProgressBar` — value `85`, max `100`
   - Progress row: `"85%"` label (MetricLabel)
   - `ShipButton` (Button) — `"🟢  SHIP IT"`, disabled
2. `ActionButtons` — `HBoxContainer` anchored to bottom:
   - `WorkButton` (Button) — `"WORK"`, disabled
   - `HustleButton` (Button) — `"HUSTLE"`, disabled

**Files touched:**
- `scenes/game_ui.tscn`

**Acceptance Criteria:**
- [ ] Task card visible between top bar and bottom buttons
- [ ] Title at 28px, progress % and deadline at 24px
- [ ] Progress bar shows ~85% filled
- [ ] SHIP IT on the card, WORK + HUSTLE at the bottom
- [ ] All three buttons disabled (greyed out)
- [ ] `/check` passes, `/look` confirms layout

**Notes:**
- Hardcoded data only — Step 4 wires to JSON
- Bug count and strike display are not in this step — added in Step 8
- `[JUICE]` bar flash on progress delta — skip for now, plain bar only

---

## Step 4 — Task Card (from JSON)

**Goal:** Task card populates from real data. All balance values loaded from JSON.

**What to build:**

1. `data/tutorial_tasks.json` — first 3 tasks in order:
   ```json
   [
     { "title": "Make the logo 10% bigger", "complexity": 1, "deadline_days": 3 },
     { "title": "Fix the flaky tests", "complexity": 1, "deadline_days": 3 },
     { "title": "Fix the 847 linting warnings", "complexity": 2, "deadline_days": 3 }
   ]
   ```
   - `deadline_days` is a relative window — TaskManager adds it to the current day when the task is assigned
2. `data/balance.json` — all values from `docs/BALANCE.md`:
   ```json
   {
     "win_goal": 5000, "bug_spiral_threshold": 100, "max_strikes": 3,
     "payday_interval": 5, "salary_per_payday": 500,
     "hustle_income": 200,
     "detection_base": 0.10, "detection_overdue_bonus": 0.20,
     "detection_strike1_bonus": 0.10, "detection_strike2_bonus": 0.20,
     "bug_penalty_per_bug": 0.01, "bugs_per_incomplete_percent": 0.1,
     "ship_minimum_progress": 50, "ship_vibe_green": 80, "ship_vibe_yellow": 60
   }
   ```
3. `task_manager.gd` — load tutorial_tasks.json, expose `current_task`, emit `task_changed(task_data)`
4. `game_manager.gd` — load balance.json in `_ready()`, store values
5. `game_ui.tscn` — attach script `game_ui.gd`
6. `game_ui.gd` — connect to `TaskManager.task_changed`, populate card from task_data:
   - Title, complexity emoji (repeat "🍝" × complexity), deadline, progress bar, progress %

**Files touched:**
- `data/tutorial_tasks.json` (new)
- `data/balance.json` (new)
- `autoloads/task_manager.gd`
- `autoloads/game_manager.gd`
- `scenes/game_ui.tscn` (add script reference)
- `scenes/game_ui.gd` (new)

**Acceptance Criteria:**
- [ ] Task card shows title, complexity, deadline from JSON (not hardcoded)
- [ ] Changing task in JSON updates the card
- [ ] `/check` passes with no errors

**Notes:**
- All tasks start at 0% progress — no `start_progress` field needed
- `deadline_days` is relative — TaskManager computes absolute deadline on assignment
- Random task pool is post-V1 — after tutorial tasks, loop or hold on last task for now
- All balance values must be in balance.json from this point — no magic numbers in code
- Buttons remain disabled — no signals wired yet

---

## Step 5a — Progress delta (pure function + GUT)

**Goal:** Core progress formula extracted as a testable pure function. GUT installed.

**What to build:**

1. Install GUT plugin into `addons/gut/`
2. `game_manager.gd` — add `calculate_progress_delta(complexity: int, bugs: int) -> float`:
   ```gdscript
   func calculate_progress_delta(complexity: int, bugs: int) -> float:
       return 100.0 / (complexity * (1.0 + bugs * balance.bug_penalty_per_bug))
   ```
3. `test/unit/test_game_manager.gd` — three cases:
   - complexity 1, 0 bugs → 100.0
   - complexity 2, 0 bugs → 50.0
   - complexity 1, 100 bugs → 50.0

**Files touched:**
- `addons/gut/` (new)
- `autoloads/game_manager.gd`
- `tests/test_game_manager.gd` (new)

**Acceptance Criteria:**
- [ ] GUT runs headlessly with no errors
- [ ] All three test cases pass
- [ ] `/check` passes

---

## Step 5b — Progress bar

**Goal:** Clicking WORK advances the progress bar. First interactive moment.

**What to build:**

1. `task_manager.gd` — `advance_progress(delta: float)`: clamp to 100, emit `task_progress_changed(progress)`
2. `game_manager.gd` — `do_work()` stub:
   ```
   1. Constraint phase — empty hook (_constraint_phase())
   2. delta = calculate_progress_delta(current_task.complexity, bugs)
   3. TaskManager.advance_progress(delta)
   4. Consequence phase — empty hook (_consequence_phase())
   ```
3. `game_ui.gd`:
   - Wire `WorkButton.pressed` → `GameManager.do_work()`, enable button
   - Connect `task_progress_changed` → update progress bar + progress label
   - Disable WorkButton when progress hits 100

**Files touched:**
- `autoloads/game_manager.gd`
- `autoloads/task_manager.gd`
- `scenes/game_ui.gd`

**Acceptance Criteria:**
- [ ] Clicking WORK increases progress bar and label
- [ ] WORK disables at 100%
- [ ] `/check` passes, `/look` confirms bar moves

**Notes:**
- Day does not increment yet — that's 5c
- `[JUICE]` progress flash — skip, plain bar update only

---

## Step 5c — Day counter

**Goal:** WORK increments the day. DayLabel updates from signal.

**What to build:**

1. `game_manager.gd`:
   - Add `var day: int = 1` with setter that emits `signal day_changed(new_day: int)`
   - `do_work()` — add `day += 1` at the end
2. `game_ui.gd`:
   - Connect `day_changed` → `"Day %d" % new_day`
   - Seed DayLabel in `_ready()` via `GameManager.day_changed.emit(GameManager.day)`

**Files touched:**
- `autoloads/game_manager.gd`
- `scenes/game_ui.gd`

**Acceptance Criteria:**
- [ ] Clicking WORK increments DayLabel
- [ ] DayLabel shows correct value on startup (Day 1)
- [ ] `/check` passes

---

## Step 6 — HUSTLE button + money

**Goal:** Clicking HUSTLE earns money and advances the day. MoneyLabel wired.

**What to build:**

1. `game_manager.gd`:
   - Add `var money: int = 0` with setter that emits `signal money_changed(new_money: int)`
   - `_do_bookkeeping()` — payday check (`day % payday_interval == 0` → `money += salary`)
   - `_check_game_state()` — win check: `money >= win_goal → game_over("win")`
   - `do_work()` — add `_do_bookkeeping()` and `_check_game_state()` calls
   - `do_hustle()`:
     ```
     1. Constraint phase — _constraint_phase()
     2. money += hustle_income
     3. Consequence phase — _consequence_phase() [detection roll added in Step 9]
     4. _do_bookkeeping()
     5. _check_game_state()
     6. day += 1
     ```
2. `game_ui.gd`:
   - Wire `HustleButton.pressed` → `GameManager.do_hustle()`, enable button
   - Connect `money_changed` → `"💰 $%d / $%d" % [new_money, GameManager.balance.win_goal]`
   - Seed MoneyLabel in `_ready()`

**Files touched:**
- `autoloads/game_manager.gd`
- `scenes/game_ui.gd`

**Acceptance Criteria:**
- [ ] Clicking HUSTLE adds $200 to MoneyLabel
- [ ] Payday fires every 5 days when WORKing (money increases)
- [ ] Day increments on HUSTLE
- [ ] Reaching $5,000 triggers game_over("win") — signal fires, nothing visible yet
- [ ] `/check` passes

**Notes:**
- Detection roll is wired in Step 9 — `_consequence_phase()` hook is already there, just empty

---

## Step 7 — SHIP IT button

**Goal:** Shipping loads the next task. First playable end-to-end loop (task 1 → 2 → 3 → 3 → 3...). Bugs deferred to Step 8.

### Step 7a — `ship_current()` in TaskManager + GUT tests

**What to build:**

1. `task_manager.gd` — `ship_current(current_day: int)`:
   - If not on last tutorial task: advance index, call `_assign_task`
   - If on last tutorial task: reset progress only (hold on task 3)

**Files touched:**
- `autoloads/task_manager.gd`
- `test/unit/test_task_manager.gd`

**Acceptance Criteria:**
- [ ] GUT: ships from task 0 → 1, resets progress
- [ ] GUT: holds on last task (task 2), resets progress
- [ ] `/check` passes

---

### Step 7b — `do_ship()` stub + wire ShipButton

**What to build:**

1. `game_manager.gd` — `do_ship()` stub (no bug calculation yet):
   ```
   1. Constraint phase
   2. TaskManager.ship_current(day)
   3. Consequence phase
   4. _do_bookkeeping()
   5. _check_game_state()
   6. day += 1
   ```
2. `game_ui.gd` — wire ShipButton:
   - Enable above `ship_minimum_progress` (from balance.json), disable below
   - Connect to `GameManager.do_ship()`
   - Update enabled state on `task_progress_changed`

**Files touched:**
- `autoloads/game_manager.gd`
- `scenes/game_ui.gd`

**Acceptance Criteria:**
- [ ] SHIP IT disabled below 50% progress
- [ ] Clicking ships task, loads next task, progress bar resets
- [ ] Day advances on ship
- [ ] `/check` passes, play through all 3 tutorial tasks

**Notes:**
- Vibe indicator (🟢/🟡/🔴) deferred — see DECISIONS.md
- Bug accumulation on ship deferred to Step 8

---

## Step 8 — Bugs + Consequences

### Step 8a-i — Bug calculation (logic + tests)

**Goal:** Shipping incomplete tasks adds bugs. Bugs slow WORK. First feedback loop.

**What you'll see while playing:** Nothing yet — this is invisible logic only. But if you ship a task at 30% and then keep WORKing, WORK will feel slightly slower than before (bugs are accumulating and dragging the progress formula). You won't be able to see why until 8a-ii.

**What to build:**

1. `game_manager.gd` — add setter to `bugs` var, emitting `bugs_changed(new_bugs)`
2. `game_manager.gd` — extract `calculate_bugs_for_ship(progress: float) -> float` pure function:
   - `return (TaskManager.TASK_MAX_PROGRESS - progress) * balance.bugs_per_incomplete_percent`
3. `game_manager.gd` — call it in `do_ship()`: `bugs += calculate_bugs_for_ship(TaskManager.current_progress)`
4. GUT tests (`test_game_manager.gd`): correct bugs added at 0%, 50%, 100% progress

**Files touched:**
- `autoloads/game_manager.gd`
- `test/unit/test_game_manager.gd`

**Acceptance Criteria:**
- [ ] GUT: shipping at 0% adds `100 * bugs_per_incomplete_percent` bugs
- [ ] GUT: shipping at 100% adds 0 bugs
- [ ] GUT: shipping at 50% adds the expected half-penalty
- [ ] WORK slows down as bugs accumulate (formula already accounts for this)
- [ ] `/check` passes

---

### Step 8a-ii — Bug count in TopBar (UI)

**Goal:** Bug count visible on screen when bugs > 0.

**What you'll see while playing:** The top bar stays clean at game start. Ship a task before it's done and a bug count appears. Ship another sloppy one and it goes up. Now you can see the rot accumulating — and feel WORK getting harder as the number climbs.

**What to build:**

1. `game_ui.tscn` — add `BugLabel` to TopBar, hidden by default
2. `game_ui.gd` — connect `bugs_changed`: show label and update text when `new_bugs > 0`, hide when 0

**Files touched:**
- `scenes/game_ui.tscn`
- `scenes/game_ui.gd`

**Acceptance Criteria:**
- [ ] Bug label hidden at game start
- [ ] Visible after shipping an incomplete task
- [ ] `/check` passes, `/look` confirms

---

### Step 8b-i — Remove `_consequence_phase()` (cleanup)

**Goal:** Delete the generic consequence hook. Detection logic will live directly in `do_hustle()`. `_constraint_phase()` stays — constraints are parked, not removed.

**What you'll see while playing:** Nothing — internal refactor, no behaviour change.

**What to build:**

1. `game_manager.gd` — remove `_consequence_phase()` method and all three call sites (`do_work`, `do_hustle`, `do_ship`)

**Files touched:**
- `autoloads/game_manager.gd`

**Acceptance Criteria:**
- [ ] No `_consequence_phase` anywhere in codebase
- [ ] `_constraint_phase()` still present in all three action methods
- [ ] `/check` passes, GUT suite still green

---

### Step 8b-ii — Overdue flag (logic + tests)

**Goal:** Game knows when the current task is past its deadline.

**What you'll see while playing:** Nothing yet — the flag is tracked silently. It only matters because being overdue increases detection chance in 8b-iii. On its own, missing a deadline has no visible consequence here.

**What to build:**

1. `game_manager.gd` — add `task_overdue: bool = false`
2. `game_manager.gd` — extract `_is_task_overdue(day: int, deadline_day: int) -> bool` pure function
3. `game_manager.gd` — call it in `_do_bookkeeping()`, update `task_overdue`; reset to `false` when a new task is assigned (connect to `TaskManager.task_changed`)
4. GUT tests (`test_bookkeeping.gd`): flag correct when day > deadline, not before, not on deadline day

**Files touched:**
- `autoloads/game_manager.gd`
- `test/unit/test_bookkeeping.gd`

**Acceptance Criteria:**
- [ ] GUT: overdue = false when day <= deadline_day
- [ ] GUT: overdue = true when day > deadline_day
- [ ] `/check` passes

---

### Step 8b-iii — Detection roll + strikes (logic + tests)

**Goal:** Hustling risks detection. 3 strikes = fired.

**What you'll see while playing:** HUSTLE now carries real risk — spam it enough and the game will abruptly end (the `game_over("fired")` signal fires). But there's no game over screen yet (that's Step 9) and no visible strike count (that's 8b-iv), so for now it'll just hang or break silently. Play-test by watching Godot's output for the signal, or temporarily print to confirm it fires.

**What to build:**

1. `game_manager.gd` — add `strikes: int` with setter emitting `strikes_changed(new_strikes)`
2. `game_manager.gd` — extract `calculate_detection_chance(strikes: int, overdue: bool) -> float` pure function:
   - Start at `detection_base`
   - If overdue: `+= detection_overdue_bonus`
   - If strikes == 1: `+= detection_strike1_bonus`
   - If strikes == 2: `+= detection_strike2_bonus`
3. `game_manager.gd` — add `_hustle_detection()` private method, called only from `do_hustle()`:
   - `var chance := calculate_detection_chance(strikes, task_overdue)`
   - `if randf() < chance: strikes += 1`
   - `if strikes >= balance.max_strikes: game_over.emit("fired")`
4. GUT tests (`test_game_manager.gd`):
   - `calculate_detection_chance` correct for all strike/overdue combinations
   - Setting `strikes = max_strikes` and calling `_check_game_state()` emits `game_over("fired")` — or test directly via `_hustle_detection()` with chance forced to 1.0

**Files touched:**
- `autoloads/game_manager.gd`
- `test/unit/test_game_manager.gd`

**Acceptance Criteria:**
- [ ] GUT: detection chance formula correct at 0/1/2 strikes × overdue/not
- [ ] GUT: 3 strikes emits `game_over("fired")`
- [ ] HUSTLE has a chance to add a strike (verify by spamming HUSTLE)
- [ ] `/check` passes

**Notes:**
- The random roll itself is not tested — only the chance formula and the fired outcome
- Overdue-while-on-PIP auto-fire from BALANCE.md — parked, add if time allows
- `[JUICE]` strike flash / warning animation — skip for now

---

### Step 8b-iv — Strike indicator (UI)

**Goal:** Strikes visible on screen after first detection.

**What you'll see while playing:** The top bar stays clean when you're behaving. Hustle and get caught — a strike appears. Get caught again — another. Three strikes and the fired condition fires. Now you can feel the risk building with every HUSTLE. This is the first time the detection system is fully legible to a player.

**What to build:**

1. `game_ui.tscn` — add strike indicator to TopBar (e.g. `StrikeLabel`), hidden by default
2. `game_ui.gd` — connect `strikes_changed`: show and update when `new_strikes > 0`, hide when 0

**Files touched:**
- `scenes/game_ui.tscn`
- `scenes/game_ui.gd`

**Acceptance Criteria:**
- [ ] Strike indicator hidden at game start
- [ ] Appears after first detection hit
- [ ] `/check` passes, `/look` confirms

---

## Steps 9 + 10 — Game over → Recap ✅

**Goal:** Game ends cleanly, transitions to a recap screen, Play Again resets the run.

Skipped `GameOverPanel` entirely — `game_over` goes straight to a scene transition.

**What was built:**

1. `game_manager.gd` — bug spiral check in `_check_game_state()` (`bugs >= bug_spiral_threshold → game_over("bug_spiral")`), with `return` to prevent double-emit
2. `game_manager.gd` — `reset()` resets day/money/bugs/strikes/task_overdue
3. `task_manager.gd` — `reset()` resets index, progress, assigns task 0 at day 1
4. `game_ui.gd` — `game_over` signal → `change_scene_to_file("res://scenes/recap.tscn")`
5. `scenes/recap.tscn` + `scenes/recap.gd` — EndingTitleLabel (48px), DayLabel, EndingQuoteLabel (autowrap), PlayAgainButton; Play Again calls `GameManager.reset()` + `TaskManager.reset()` then reloads `game_ui.tscn`
6. GUT tests — bug spiral emits `game_over("bug_spiral")` at threshold; no signal below threshold; `test_bookkeeping.gd` balance dict updated with `bug_spiral_threshold`

**Acceptance Criteria:**
- [x] HUSTLE to $5,000 → recap appears, correct day, Play Again works
- [x] 3 strikes → recap appears, correct day, Play Again works
- [x] Bug spiral (100 bugs) → recap appears (requires deliberate grinding at current balance values)
- [x] Play Again resets to Day 1, $0, first tutorial task
- [x] GUT suite green (31/31)
- [x] `/check` passes

**Deferred to follow-up:**
- `game_over_reason` var + outcome text in recap ("Day N — escaped / fired / buried in bugs")
- Run stat tracking (`tasks_shipped`, `ships_below_60`, `total_bugs_accumulated`)
- `get_ending()` + distinct endings (Perfectionist, Speed Runner, Technical Debt Monster, AI Prompt Engineer, Pragmatist)
- Stat labels in recap ("You shipped N tasks. N under 60%.")
