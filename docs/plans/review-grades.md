# Review Grades — Feature Plan

**Status:** Phase 1 ✅ Done · Phase 2 🔨 In Progress

Two phases: first show grades at review (display only), then wire mechanical consequences.
Both reviews (day 30, day 60) use the same grade system.

---

## Phase 1 — Grade Display

Show the player a report card at each review. Three grades, derived from existing counters.

### Grades

| Grade | Measures | Calculation |
|-------|----------|-------------|
| Quality | Sloppy ship rate | `1 - (sloppy_ships / tasks_shipped)` |
| Output | Tasks shipped in period | `tasks_shipped` (raw count vs thresholds) |
| Timeliness | On-time vs late ships | `tasks_on_time / (tasks_on_time + tasks_late)` |

Output uses raw count, not a ratio. No complexity weighting yet — defer until tier 2 tasks are better understood.

### Grade Labels (corporate language)

- **Exceeds Expectations**
- **Meets Expectations**
- **Needs Improvement**

### Thresholds

Each metric has its own two thresholds in `balance.json`. Ratio above `exceeds` → Exceeds, above `meets` → Meets, else Needs Improvement.

```json
"quality_grade_exceeds": 0.9,
"quality_grade_meets": 0.6,
"output_grade_exceeds": 8,
"output_grade_meets": 5,
"timeliness_grade_exceeds": 0.8,
"timeliness_grade_meets": 0.5
```

Output thresholds based on log analysis: wins ship ~9–10 tasks per 30-day period, 5–7 is solid, <5 is struggling. Starting values — tune via playtesting.

### Edge Cases

- `tasks_shipped = 0` → Quality and Timeliness return "Needs Improvement" (no division); Output returns "Needs Improvement"
- `tasks_on_time + tasks_late = 0` → Timeliness returns "Needs Improvement"

### UI

Extend `review_dialog.gd` and `review_dialog.tscn` to show grades alongside the existing raw counters.
No new scene needed — add grade labels to the existing layout.

### Implementation Order (one metric at a time)

1. Quality grade — TDD: failing test → `calculate_quality_grade()` in `GameManager` → pass
2. Quality grade display in review dialog
3. Output grade — TDD: failing test → `calculate_output_grade()` in `GameManager` → pass
4. Output grade display in review dialog
5. Timeliness grade — TDD: failing test → `calculate_timeliness_grade()` in `GameManager` → pass
6. Timeliness grade display in review dialog

### GUT Tests

**Quality:**
- Returns "Exceeds Expectations" when sloppy rate is low
- Returns "Meets Expectations" when sloppy rate is mid
- Returns "Needs Improvement" when sloppy rate is high
- Edge: all tasks sloppy → Needs Improvement
- Edge: zero tasks shipped → Needs Improvement (no crash)

**Output:**
- Returns "Exceeds Expectations" when tasks_shipped >= exceeds threshold
- Returns "Meets Expectations" when tasks_shipped >= meets threshold
- Returns "Needs Improvement" when tasks_shipped below meets threshold
- Edge: zero tasks shipped → Needs Improvement

**Timeliness:**
- Returns "Exceeds Expectations" when mostly on time
- Returns "Meets Expectations" when mixed
- Returns "Needs Improvement" when mostly late
- Edge: zero tasks shipped → Needs Improvement (no crash)

---

## Phase 2 — PIP Mechanic

### Design

Hustle detection is **zero by default**. Any "Needs Improvement" grade at a review puts the player on a
Performance Improvement Plan (PIP). While on PIP, hustle detection kicks in — the boss is watching.

| State | Detection chance |
|-------|-----------------|
| Normal | 0 (base rate off) |
| On PIP | `pip_detection_base` (explicit balance key) |

**PIP trigger:** any single "Needs Improvement" across any metric → `on_pip = true`.

**PIP clears:** if all grades at the next review are "Meets" or "Exceeds" → `on_pip = false`.

**Fired:** if still on PIP at next review and any grade is still "Needs Improvement" → `game_over("fired_pip")`.

This is the simpler implementation (any NI while on PIP = fired, not per-metric tracking). Can be tightened
to per-metric later if needed — the state change is small.

### Balance keys

```json
"detection_base": 0,
"pip_detection_base": 0.15
```

`detection_base` is kept explicit at 0 in case other factors are added later (e.g. consecutive hustle
penalty). `pip_detection_base` is the separate rate that applies only while on PIP.

### Implementation

- Add `on_pip: bool = false` to `GameManager`
- `_check_game_state("hustle")` uses `pip_detection_base` when `on_pip`, else 0
- PIP flag evaluated in `_on_continue()` in `review_dialog.gd` after grades are read, before `reset_review_counters()`
- `on_pip` resets in `reset()`

### GUT Tests

- `on_pip` set to true when any grade is "Needs Improvement"
- `on_pip` cleared when all grades meet or exceed at next review
- Hustle detection is 0 when not on PIP
- Hustle detection uses `pip_detection_base` when on PIP
- `game_over("fired_pip")` emitted when on PIP and any grade still "Needs Improvement"

### Commit Plan

1. `balance.json` — set `detection_base: 0`, add `pip_detection_base: 0.15`
2. `on_pip` flag in `GameManager` + detection logic update + tests
3. PIP evaluation in `review_dialog.gd` `_on_continue()` + fired_pip condition + tests

---

## Dependencies

- Existing review counters (`tasks_shipped`, `sloppy_ships`, etc.) — already built
- Review dialog already fires at day 30 and day 60 — already built
- Phase 2 depends on Phase 1 landing and feeling right via playtesting

---

## Phase 1 — Commit Plan

### Commit 1 — `balance.json` grade thresholds
Add the six threshold keys to `data/balance.json`. No logic yet — just data.
```
feat: add grade threshold keys to balance.json
```

### Commit 2 — `calculate_quality_grade()` + tests
TDD: write failing tests first, then implement in `autoloads/game_manager.gd`.
- Returns "Exceeds Expectations" / "Meets Expectations" / "Needs Improvement"
- Guards zero tasks_shipped
```
feat: add calculate_quality_grade() to GameManager
```

### Commit 3 — Quality grade in review dialog
Add grade label to `scenes/review_dialog.tscn` / `scenes/review_dialog.gd`, below the existing raw counters. `/check` + `/look` to verify.
```
feat: show quality grade in review dialog
```

### Commit 4 — `calculate_output_grade()` + tests
TDD: failing tests first, then implement. Raw count vs thresholds, zero guard.
```
feat: add calculate_output_grade() to GameManager
```

### Commit 5 — Output grade in review dialog
```
feat: show output grade in review dialog
```

### Commit 6 — `calculate_timeliness_grade()` + tests
TDD: failing tests first, then implement. Ratio guard for zero tasks.
```
feat: add calculate_timeliness_grade() to GameManager
```

### Commit 7 — Timeliness grade in review dialog
```
feat: show timeliness grade in review dialog
```
