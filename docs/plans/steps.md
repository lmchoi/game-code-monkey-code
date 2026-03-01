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
- Hardcoded strings only — wiring to GameManager signals is Step 3
- Dark background on the top bar is fine but not required at this step — focus on layout
