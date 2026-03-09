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

| Type | Complexity | Deadline | Mechanic |
|------|------------|----------|----------|
| `standard` | any | normal | Existing behaviour. No change. |
| `optics` | low | tight | Ship late → immediate strike. Easy task, zero tolerance for lateness. |
| `tech_debt` | high | tight | No special mechanic. The pain is the task itself — unglamorous, hard, time-consuming. |
| `critical` | any | normal | Sloppy ship → immediate strike. Quality is mandatory. |
| `compliance` | low | normal | Ship it → task done, -1 duck. Let it go overdue → strike risk, duck preserved. Only type where not shipping is a legitimate strategy. Tracked in recap. |

**Narrative arc:** optics (time pressure) → tech_debt (complexity pressure) → critical (quality pressure) → moral (conscience pressure).

**Task descriptions:** Optics tasks are low-complexity political requests devs will recognise ("Add 'AI-powered' to the landing page by EOD"). Tech debt tasks are tedious and unglamorous ("Migrate the legacy auth tables. No docs."). Critical tasks feel high-stakes ("Patch the payment service before the audit"). Moral tasks are ethically questionable requests the business frames as normal ("Scrape competitor pricing data. Don't log it.").

**Recap / endings:** moral task acceptance rate is tracked and surfaces in the run recap and victory ending triggers. A player who always accepted moral tasks gets a different flavour than one who pushed back.

**Dependency:** requires ducks mechanic (v1+). Don't build until ducks are implemented.

**Parked idea:** probability of drawing a `tech_debt` task increases as bug count rises — the more you've shipped sloppily, the more cleanup lands in your queue. Don't build until weighted task draw logic exists.

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
    "critical":
        if was_sloppy:
            strikes += 1
            # existing bug logic still runs
```

### balance.json

No new keys required.

### GUT Tests

- `optics` overdue ship adds a strike
- `optics` on-time ship does not add extra strike
- `critical` sloppy ship adds a strike
- `critical` clean ship does not add a strike
- `tech_debt` ship has no special consequence
- `standard` ship behaviour unchanged

---

## Dependencies

- Task pool tier sequence — already built
- Review grades (mechanical consequences) — parallel; task types don't depend on grades

---

## Suggested Commit Order

1. Add `type` field to all tasks in `data/tasks.json` (data only, including new optics/tech_debt/critical task titles)
2. `do_ship()` type dispatch in `game_manager.gd` + GUT tests (TDD)
3. Task card label — coloured pill showing type name (e.g. "OPTICS", "TECH DEBT", "CRITICAL"), visible before the player commits. `/look` to verify.
