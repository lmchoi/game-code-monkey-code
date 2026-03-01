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
| Overdue (fired) | Overdue ≥ 3 days AND already on strike |

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

| Phase | Complexity | Deadline |
|-------|------------|----------|
| Task 1 (fixed) | 🍝 (1) | Long (Day 6) |
| Task 2 (fixed) | 🍝🍝 (2) | Medium |
| Task 3 (fixed) | 🍝🍝 (2) | Tight |
| Pool tasks | Scales over time | Scales over time |

---

## Parked for V1

The following exist in the design but are not implemented in V1:

- Ducks (needs moral choice triggers)
- Promotion / golden handcuffs mechanic
- Task categories (optics / tech debt / critical)
- Production outages / blame mechanic
- Random work events
