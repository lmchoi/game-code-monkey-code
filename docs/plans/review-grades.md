# Review Grades — Feature Plan

**Status:** 💡 Idea

Two phases: first show grades at review (display only), then wire mechanical consequences.
Both reviews (day 30, day 60) use the same grade system.

---

## Phase 1 — Grade Display

Show the player a report card at each review. Three grades, derived from existing counters.

### Grades

| Grade | Measures | Source |
|-------|----------|--------|
| Quality | Sloppy ship rate, bugs added | `sloppy_ships`, `total_bugs_added`, `tasks_shipped` |
| Output | Tasks completed, weighted by complexity | `tasks_shipped` (complexity weight TBD) |
| Timeliness | On-time vs late ships | `tasks_on_time`, `tasks_late` |

Each grade: Good / Okay / Poor. Thresholds set in `balance.json`, tuned via playtesting.

### UI

Extend `review_dialog.gd` and `review_dialog.tscn` to show grades alongside the existing counters.
No new scene needed — add grade labels to the existing layout.

### GUT Tests

- `calculate_quality_grade()` returns correct grade for given inputs
- `calculate_output_grade()` returns correct grade
- `calculate_timeliness_grade()` returns correct grade
- Edge: all tasks sloppy → Poor quality
- Edge: zero tasks shipped → grades handle gracefully

---

## Phase 2 — Mechanical Consequences

Grades translate into modifiers that affect the remainder of the run.
Applied once at the review, persisted in `GameManager`.

### Candidate consequences (to tune via playtesting)

| Grade result | Effect |
|--------------|--------|
| Quality: Good | Bug penalty on work reduced slightly |
| Quality: Poor | Bug penalty on work increased |
| Output: Good | Salary bonus (+$X per payday) |
| Output: Poor | No salary change |
| Timeliness: Good | Detection base rate lowered |
| Timeliness: Poor | Detection base rate raised |

### Implementation

- Add modifier fields to `GameManager` (e.g. `work_efficiency_modifier`, `salary_bonus`, `detection_modifier`)
- Consequences applied in `review_dialog.gd` `_on_continue_pressed()` after `unlock_next_tier()`
- All modifier values in `balance.json`

### GUT Tests

- Applying Good quality grade reduces bug penalty modifier
- Applying Poor timeliness grade raises detection modifier
- Modifiers persist after review (not reset until `game_over`)

---

## Dependencies

- Existing review counters (`tasks_shipped`, `sloppy_ships`, etc.) — already built
- Review dialog already fires at day 30 and day 60 — already built
- Phase 2 depends on Phase 1 landing and feeling right via playtesting

---

## Suggested Commit Order

1. `calculate_*_grade()` functions in `GameManager` + GUT tests (TDD)
2. Grade display in `review_dialog.tscn` / `review_dialog.gd`
3. Mechanical consequence modifiers in `GameManager` + GUT tests (TDD)
4. Apply consequences in `review_dialog.gd`
5. `balance.json` — grade thresholds and modifier values
