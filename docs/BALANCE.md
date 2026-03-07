# The Daily Grind — Balance Reference

**Mode:** grind (V1)

> These are the design-side defaults. All values must also exist in `data/balance.json` — that file is the implementation source of truth. When you change a number here, update the JSON too.

---

## Starting State

| Resource | Start Value |
|----------|-------------|
| Money | $0 |
| Bugs | 0 |
| Day | 1 |

---

## Win / Loss Thresholds

| Condition | Threshold |
|-----------|-----------|
| Victory | $5,000 saved |
| Death spiral | 100+ bugs |
| Fired | 3 strikes |
| Overdue (fired) | Overdue ≥ 3 days AND already on strike — **not implemented, parked** |

---

## Actions

### WORK

```
daily_progress = 100.0 / (complexity × bug_multiplier)
bug_multiplier = 1.0 + (bugs × 0.01)
```

Examples:
| Complexity | Bugs | Days to Complete |
|------------|------|-----------------|
| 1 | 0 | 1 day |
| 2 | 0 | 2 days |
| 3 | 0 | 3 days |
| 2 | 50 | ~4 days |
| 3 | 80 | ~15 days |

### HUSTLE

- Payment: $200/day
- Detection chance (base): 10%
- Detection chance if task overdue: +20%
- Detection chance after Strike 1: +10%
- Detection chance after Strike 2: +20%

### SHIP IT

- Minimum shippable: 50% progress
- Bugs added: `(100 - progress) × bugs_per_incomplete_percent`
- `bugs_per_incomplete_percent` = 0.1 (i.e. ship at 50% → 5 bugs)

---

## Ship Vibe Thresholds

| Progress at ship | Vibe | Bugs added (approx) |
|------------------|------|----------------------|
| 80–100% | 🟢 Green | 0–2 |
| 60–79% | 🟡 Yellow | 2–4 |
| 50–59% | 🔴 Red | 4–5 |
| <50% | Blocked | — |

---

## Salary & Payday

- Salary per payday: $500
- Payday every: 5 days

---

## Task Difficulty Curve

| Phase | Title | Complexity | Deadline window |
|-------|-------|------------|-----------------|
| Task 1 (fixed) | "Make the logo 10% bigger" | 🍝 (1) | 3 days |
| Task 2 (fixed) | "Fix the flaky tests" | 🍝 (1) | 3 days |
| Task 3 (fixed) | "Fix the 847 linting warnings" | 🍝🍝 (2) | 3 days |
| Pool tasks | Varies | Scales over time | Scales over time |

---

## Parked for V1

The following exist in the design but are not implemented in V1:

- Ducks (needs moral choice triggers)
- Promotion / golden handcuffs mechanic
- Task categories (optics / tech debt / critical)
- Production outages / blame mechanic
- Random work events

---

## Ideas

### Time pressure / game length cap

Simulation findings (2026-03-07): pure-work strategies (`diligent_worker`, `ship_asap`) win 100% of
runs at a deterministic day 51. There is no time pressure — a patient player cannot lose. Meanwhile,
`hustle_then_ship` wins at day 22 but only 35% of the time due to detection risk.

**Idea:** add a hard game-over at day ~30 (or a soft performance-review strike if not at X% of the
money goal). This would:
- Make pure-work unviable on its own — day 51 is out of reach
- Make some hustling mandatory, raising the stakes
- Make `hustle_then_ship`-style play the intended path, with detection risk as the core tension

Soft variant: at day 30, a "performance review" adds a strike if money < some threshold. Keeps the
game alive but punishes slowness without a hard cutoff.
