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
     { "title": "Build a blockchain todo app", "complexity": 1, "deadline_day": 6, "start_progress": 85 },
     { "title": "...", "complexity": 2, "deadline_day": 10, "start_progress": 0 },
     { "title": "...", "complexity": 2, "deadline_day": 14, "start_progress": 0 }
   ]
   ```
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
- Task 1 starts at 85% progress — TaskManager must respect `start_progress`
- Random task pool is post-V1 — after tutorial tasks, loop or hold on last task for now
- All balance values must be in balance.json from this point — no magic numbers in code
- Buttons remain disabled — no signals wired yet

---

## Step 5 — WORK button

**Goal:** Clicking WORK advances progress and the day. Core loop tick. Top bar wired.

**What to build:**

1. `game_manager.gd` — add state + signals, then implement `do_work()`:
   ```gdscript
   var day: int = 1 : set = _set_day
   var money: int = 0 : set = _set_money
   signal day_changed(new_day: int)
   signal money_changed(new_money: int)
   ```
   ```
   do_work():
   1. Constraint phase — empty hook (_constraint_phase())
   2. progress_delta = 100.0 / (task.complexity * (1.0 + bugs * bug_penalty_per_bug))
   3. TaskManager.advance_progress(progress_delta)
   4. Consequence phase — empty hook (_consequence_phase())
   5. Bookkeeping — _do_bookkeeping()
   6. Win/loss check — _check_game_state()
   7. day += 1
   ```
2. `_do_bookkeeping()` — payday check (`day % payday_interval == 0` → `money += salary`)
3. `_check_game_state()` — loss only for now: bugs >= bug_spiral_threshold → emit `game_over("bug_spiral")`
4. `task_manager.gd` — `advance_progress(delta)`, clamp to 100, emit `task_progress_changed(progress)`
5. `game_ui.gd`:
   - Connect `day_changed` → `"Day %d" % new_day`
   - Connect `money_changed` → `"💰 $%d / $%d" % [new_money, balance.win_goal]`
   - Call `GameManager.day_changed.emit(1)` and `GameManager.money_changed.emit(0)` in `_ready()` to seed initial display
   - Wire `WorkButton.pressed` → `GameManager.do_work()`
   - Update progress bar + label on `task_progress_changed`
   - Disable WorkButton when progress hits 100

**Files touched:**
- `autoloads/game_manager.gd`
- `autoloads/task_manager.gd`
- `scenes/game_ui.gd`

**Acceptance Criteria:**
- [ ] Clicking WORK increases progress bar
- [ ] Day counter and money label update from signals (not hardcoded)
- [ ] Payday fires every 5 days (money increases)
- [ ] WORK disables when task hits 100%
- [ ] `/check` passes, game is playable

**Notes:**
- Overdue check is added in Step 8 alongside other consequences
- `game_over` signal fires but nothing handles it yet — that's Step 9
- `[JUICE]` progress flash on delta — skip, plain bar update only

---

## Step 6 — HUSTLE button

**Goal:** Clicking HUSTLE earns money and advances the day.

**What to build:**

1. `game_manager.gd` — `do_hustle()`:
   ```
   1. Constraint phase — _constraint_phase()
   2. money += hustle_income
   3. Consequence phase — _consequence_phase() [detection roll added in Step 8]
   4. _do_bookkeeping()
   5. _check_game_state() — add win check: money >= win_goal → game_over("win")
   6. day += 1
   ```
2. `game_ui.gd` — wire `HustleButton.pressed` → `GameManager.do_hustle()`

**Files touched:**
- `autoloads/game_manager.gd`
- `scenes/game_ui.gd`

**Acceptance Criteria:**
- [ ] Clicking HUSTLE adds $200 to money display
- [ ] Day increments
- [ ] Reaching $5,000 triggers game_over("win") — nothing visible yet, just verify signal fires
- [ ] `/check` passes

**Notes:**
- Detection roll is wired in Step 8 — `_consequence_phase()` hook is already there, just empty

---

## Step 7 — SHIP IT button

**Goal:** Shipping completes the task, adds bugs, loads the next task.

**What to build:**

1. `game_manager.gd` — `do_ship()`:
   ```
   1. Constraint phase
   2. progress = TaskManager.current_progress
   3. bugs_added = (100 - progress) * bugs_per_incomplete_percent
   4. bugs += bugs_added
   5. TaskManager.ship_current() → loads next task
   6. Consequence phase
   7. _do_bookkeeping()
   8. _check_game_state()
   9. day += 1
   ```
2. `task_manager.gd` — `ship_current()`, advance to next tutorial task (or loop)
3. Vibe indicator — update ShipButton text before player acts:
   - progress >= 80: `"🟢  SHIP IT"`
   - progress >= 60: `"🟡  SHIP IT"`
   - progress >= 50: `"🔴  SHIP IT"`
   - progress < 50: button disabled, `"SHIP IT"` (greyed)
4. `game_ui.gd` — wire ShipButton, update vibe on `task_progress_changed`

**Files touched:**
- `autoloads/game_manager.gd`
- `autoloads/task_manager.gd`
- `scenes/game_ui.gd`

**Acceptance Criteria:**
- [ ] SHIP IT disabled below 50% progress
- [ ] Button shows correct vibe emoji for current progress
- [ ] Clicking ships task, adds bugs, loads next task
- [ ] Progress bar resets for new task
- [ ] `/check` passes

**Notes:**
- Vibe thresholds come from balance.json (`ship_vibe_green`, `ship_vibe_yellow`, `ship_minimum_progress`)
- Bug feedback shown only as vibe emoji (not exact count) per DECISIONS.md open decision
- `bugs_signal` should emit on change so UI can show bug count when > 0 (Step 8)

---

## Step 8 — Consequences

**Goal:** Hustling risks detection. Shipping adds visible bugs. Strikes show on screen.

**What to build:**

1. `game_manager.gd` — fill `_consequence_phase()` for HUSTLE:
   - `detection_chance = detection_base`
   - If task overdue: `+= detection_overdue_bonus`
   - If strikes == 1: `+= detection_strike1_bonus`
   - If strikes == 2: `+= detection_strike2_bonus`
   - Roll: `if randf() < detection_chance → strikes += 1`
   - If strikes >= 3: `game_over("fired")`
2. `game_manager.gd` — add `bugs` var with signal `bugs_changed(new_bugs)`, `strikes` var with signal `strikes_changed(new_strikes)`
3. `game_ui.gd` — show bug count when > 0, show strike icons when > 0
4. `game_ui.tscn` — add bug display (hidden, in or below TopBar) + strike display (hidden)
5. Overdue check in `_do_bookkeeping()`: if `day > task.deadline_day → task_overdue = true`

**Files touched:**
- `autoloads/game_manager.gd`
- `scenes/game_ui.tscn`
- `scenes/game_ui.gd`

**Acceptance Criteria:**
- [ ] HUSTLE has a chance to add a strike (verify by spamming HUSTLE)
- [ ] 3 strikes fires `game_over("fired")`
- [ ] Bug count appears on screen when bugs > 0
- [ ] Strike indicator appears after first strike
- [ ] Task overdue flag set correctly when day > deadline
- [ ] `/check` passes

**Notes:**
- Overdue-while-on-PIP firing condition from BALANCE.md (`overdue >= 3 days AND already on strike`) — add if time allows, otherwise parked
- `[JUICE]` strike flash / warning animation — skip for now

---

## Step 9 — Win / loss screen

**Goal:** Game ends cleanly. Buttons disabled, reason shown. Recap is Step 10.

**What to build:**

1. `game_ui.tscn` — add `GameOverPanel` (full-screen overlay, hidden by default):
   - `EndGameTitle` label (EndGameTitle variation, 48px)
   - `ReasonLabel` label
   - `PlayAgainButton` (Button)
2. `game_ui.gd` — connect `GameManager.game_over(reason)`:
   - Disable all buttons
   - Show GameOverPanel with correct message:
     - `"win"` → title `"You escaped."`, reason `"You saved $5,000."`
     - `"bug_spiral"` → title `"Death spiral."`, reason `"100 bugs. Nothing works."`
     - `"fired"` → title `"Security will escort you out."`, reason `"3 strikes."`
   - `PlayAgainButton` → reload scene (`get_tree().reload_current_scene()`)
3. `game_manager.gd` — track run stats for recap: `days_survived`, `tasks_shipped`, `total_bugs_accumulated`, `ships_below_60` (count)

**Files touched:**
- `scenes/game_ui.tscn`
- `scenes/game_ui.gd`
- `autoloads/game_manager.gd`

**Acceptance Criteria:**
- [ ] Win, bug spiral, and fired conditions each show the right message
- [ ] All buttons disabled on game over
- [ ] Play Again resets the game
- [ ] `/check` passes, play a full game end-to-end

---

## Step 10 — Recap screen

**Goal:** End of run shows a Frostpunk-style recap with every key stat and an ending title.

**What to build:**

1. `scenes/recap.tscn` (new scene):
   - `EndGameTitle` label — ending name
   - Stats block (Labels):
     - `"Day {N} — {outcome}"`
     - `"You shipped {N} tasks. {N} under 60%."`
     - `"{N} bugs followed you out."`
   - Ending quote (Label)
   - `[Play Again]` button
2. `game_manager.gd` — `get_ending()` — determine ending from stats:
   - Loss endings always override
   - Win endings (check in order — first match wins):
     - `THE PERFECTIONIST` — win + total_bugs <= 10
     - `THE SPEED RUNNER` — win + days_survived <= threshold (TBD in balance.json)
     - `THE TECHNICAL DEBT MONSTER` — win + total_bugs >= 50
     - `THE AI PROMPT ENGINEER` — win + ships_below_60 >= 3
     - `THE PRAGMATIST` — win (fallback)
3. Replace `GameOverPanel` from Step 9 with transition to `recap.tscn`

**Files touched:**
- `scenes/recap.tscn` (new)
- `scenes/recap.gd` (new)
- `autoloads/game_manager.gd`

**Acceptance Criteria:**
- [ ] Recap shows correct day count, task count, bug count
- [ ] Correct ending title for each win path (test each manually)
- [ ] Loss runs show "Fired" or "Death Spiral" ending
- [ ] Play Again resets to Day 1
- [ ] `/check` passes, full run end-to-end with recap

**Notes:**
- Ending triggers from DECISIONS.md are still open — these thresholds are a starting point, tune via playtesting
- Speed Runner threshold: add `speed_runner_day_threshold` to balance.json
