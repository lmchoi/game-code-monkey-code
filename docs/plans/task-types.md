# Task Types — Feature Plan

**Status:** 📐 Planned

Add a `type` field to tasks in `data/tasks.json`. Each type has a distinct mechanical consequence
on ship, teaching new rules gradually across the tier progression.

---

## Goal

Tier1 tasks are generic — the player learns the basic loop. Typed tasks are introduced one at a
time from task 10 onwards, each adding a new rule the player must adapt to.

---

## Introduction Pacing

Types are introduced one at a time, following task sequence — not tied to reviews or tier boundaries.

| Task number (approx) | Type introduced |
|----------------------|-----------------|
| 1–9 | `standard` only — player learns the basic loop |
| ~10 | `optics` — first gotcha: timing matters, not quality |
| ~20 | `tech_debt` — tedious cleanup with a payoff |
| ~30 | `critical` — quality mandatory, no shortcuts |

Exact task numbers are tunable in `data/tasks.json` by where typed tasks appear in the draw sequence.
The ~10-task gap gives the player time to encounter the new rule, form an expectation, then be
surprised by the next one.

Whether the player sees the type on the task card before committing is **open** — defer until
playtesting reveals whether hidden types feel unfair.

---

## Task Types

| Type | Description | Mechanic |
|------|-------------|----------|
| `standard` | Normal task | Existing behaviour. No change. |
| `optics` | Bullshit business request — dumb, political, but the boss announced it in all-hands. Deadline is arbitrary and non-negotiable. | Ship late → immediate strike (deadline is political, not technical). Tight deadline in task data. |
| `tech_debt` | Tedious cleanup nobody wants to do. No glory, but the codebase thanks you. | On ship, reduce current bug count by a fixed amount. The payoff for doing the boring work. |
| `critical` | High-stakes task — the business is watching, and a bad ship will be noticed. | Sloppy ship → immediate strike. Quality is mandatory. |

**Narrative arc:** optics (timing pressure, carrot/stick) → tech_debt (cleanup payoff) → critical (quality pressure). Escalates from "don't be late" to "don't be sloppy."

**Task descriptions:** Optics tasks should read as recognisably absurd corporate requests that devs will laugh at. Tech debt tasks should feel tedious and unglamorous. Critical tasks should feel high-stakes and stressful.

---

## Implementation

### data/tasks.json

Add `"type"` field to each task. Tier1 tasks are all `"standard"`. Typed tasks appear at ~task 10, 20, 30.

```json
{ "title": "...", "complexity": 2, "deadline_days": 2, "type": "optics" }
```

### game_manager.gd — do_ship()

Read `current_task["type"]` and apply the consequence after the existing ship logic:

```gdscript
match current_task.get("type", "standard"):
    "optics":
        if is_overdue:
            strikes += 1
            # existing overdue logic still runs
    "tech_debt":
        bugs = max(0, bugs - balance.get("tech_debt_bug_reduction", 5))
    "critical":
        if was_sloppy:
            strikes += 1
            # existing bug logic still runs
```

### balance.json

```json
"tech_debt_bug_reduction": 5
```

### GUT Tests

- `optics` overdue ship adds a strike
- `optics` on-time ship does not add extra strike
- `tech_debt` ship reduces bug count
- `tech_debt` ship does not reduce below 0
- `critical` sloppy ship adds a strike
- `critical` clean ship does not add a strike
- `standard` ship behaviour unchanged

---

## Dependencies

- Task pool tier sequence — already built
- Review grades (mechanical consequences) — parallel; task types don't depend on grades

---

## Suggested Commit Order

1. Add `type` field to all tasks in `data/tasks.json` (data only, including new optics/tech_debt/critical task titles)
2. `do_ship()` type dispatch in `game_manager.gd` + GUT tests (TDD)
3. `balance.json` — `tech_debt_bug_reduction`
