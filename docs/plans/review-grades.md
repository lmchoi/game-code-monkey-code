# Review Grades — Feature Plan

**Status:** 💡 Idea

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

## Phase 2 — Mechanical Consequences

Grades translate into modifiers that affect the remainder of the run.
Applied once at the review, persisted in `GameManager`.

Phase 2 should follow Phase 1 quickly — grades feel hollow without consequences.

### Candidate consequences (to tune via playtesting)

| Grade result | Effect |
|--------------|--------|
| Quality: Exceeds | Bug penalty on work reduced slightly |
| Quality: Needs Improvement | Bug penalty on work increased |
| Output: Exceeds | Salary bonus (+$X per payday) |
| Output: Needs Improvement | No salary change |
| Timeliness: Exceeds | Detection base rate lowered |
| Timeliness: Needs Improvement | Detection base rate raised |

### Implementation

- Add modifier fields to `GameManager` (e.g. `work_efficiency_modifier`, `detection_modifier`)
- Consequences applied in `review_dialog.gd` `_on_continue_pressed()` after `unlock_next_tier()`
- All modifier values in `balance.json`

### GUT Tests

- Applying Exceeds quality grade reduces bug penalty modifier
- Applying Needs Improvement timeliness grade raises detection modifier
- Modifiers persist after review (not reset until `game_over`)

---

## Dependencies

- Existing review counters (`tasks_shipped`, `sloppy_ships`, etc.) — already built
- Review dialog already fires at day 30 and day 60 — already built
- Phase 2 depends on Phase 1 landing and feeling right via playtesting

---

## Suggested Commit Order

1. `calculate_quality_grade()` in `GameManager` + GUT tests (TDD)
2. Quality grade display in `review_dialog.tscn` / `review_dialog.gd`
3. `calculate_output_grade()` in `GameManager` + GUT tests (TDD)
4. Output grade display in `review_dialog.tscn` / `review_dialog.gd`
5. `calculate_timeliness_grade()` in `GameManager` + GUT tests (TDD)
6. Timeliness grade display in `review_dialog.tscn` / `review_dialog.gd`
7. Phase 2: consequence modifiers in `GameManager` + GUT tests (TDD)
8. Apply consequences in `review_dialog.gd`
9. `balance.json` — all thresholds and modifier values
