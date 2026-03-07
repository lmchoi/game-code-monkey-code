# Task Pool — Feature Plan

The current build has 3 fixed tutorial tasks that recycle on the last one. This feature extends
the sequence with authored tier 1 and tier 2 task lists, separated by the day 30 review.
Randomisation is deferred — the sequence is fixed and curated for now.

---

## What's Already Built

- `data/tutorial_tasks.json` — 3 fixed tasks, sequential, hold on last
- `task_manager.gd` — loads tutorial tasks, advances by index, holds on last
- `TaskManager.reset()` — resets index to 0, progress to 0, assigns task 0

---

## Structure

```
tutorial_tasks  →  tier 1 sequence  →  [day 30 review]  →  tier 2 sequence
```

- Tutorial and tier 1 are sequential and fixed
- Day 30 review fires when tier 1 is exhausted (or at day 30, whichever comes first — TBD)
- Tier 2 is a separate fixed sequence, same for everyone for now
- Tier 3 deferred — not building yet

---

## What Needs Building

### 1 — `data/tasks.json` — tier 1 and tier 2 sequences

Two arrays in one file: `tier1` and `tier2`. Both fixed and ordered.

```json
{
  "tier1": [
    { "title": "Rename a variable to fix the bug", "complexity": 1, "deadline_days": 4 },
    { "title": "Add a loading spinner to the dashboard", "complexity": 1, "deadline_days": 3 },
    { "title": "Write unit tests for code that can't be tested", "complexity": 2, "deadline_days": 4 },
    { "title": "Migrate the database. No rollback plan.", "complexity": 2, "deadline_days": 3 },
    { "title": "Estimate the rewrite. In story points.", "complexity": 2, "deadline_days": 3 }
  ],
  "tier2": [
    { "title": "Rebuild the auth system over the weekend", "complexity": 3, "deadline_days": 3 },
    { "title": "Make the app GDPR compliant by Monday", "complexity": 3, "deadline_days": 2 },
    { "title": "Fix prod. It's been down for 40 minutes.", "complexity": 3, "deadline_days": 1 },
    { "title": "Reduce load time by 80%. No new infra budget.", "complexity": 3, "deadline_days": 2 }
  ]
}
```

Aim for ~8 tasks per tier. Titles above are a starting point — tune for tone and variety.

**This commit is data-only. No code change, no functional change.**

### 2 — Sequence logic in `task_manager.gd`

After the tutorial, advance sequentially through tier 1. After tier 1 is exhausted, hold on
the last task until the day 30 review fires. After the review, switch to tier 2 and advance
sequentially. Hold on the last tier 2 task if the player keeps going.

No random draw. No repeat tracking needed.

`tasks_shipped` tracked in `GameManager` (needed for review grading and endings).

**`reset()` update:** reset tier index and active tier to tutorial.

### 3 — Balance tuning

```json
"bug_spiral_threshold": 50,
"win_goal": 10000
```

- `bug_spiral_threshold` down from 100 to 50 — makes the spiral reachable in ~10 bad ships
- `win_goal` up from 5000 to 10000 — baby step toward a longer arc, tune further after playtesting

---

## GUT Tests

Write before implementing commit 2:

- After tutorial exhausted, next task comes from tier 1
- Tier 1 advances sequentially
- Tier 1 holds on last task when exhausted (until review fires)
- After review, next task comes from tier 2
- Tier 2 advances sequentially
- Tier 2 holds on last task when exhausted

---

## Open Questions

- **Review trigger:** does tier 1 → review happen at day 30, or when tier 1 is exhausted, or whichever comes first?
- **Task count per tier:** 8 is the target. More is a pure data change.
- **Complexity within tiers:** tier 1 = complexity 1–2, tier 2 = complexity 2–3. Hardcoded via data.
- **Randomisation:** deferred. Add in a later pass once the authored sequence feels right.

---

## Suggested Commit Order

1. `data/tasks.json` — tier 1 and tier 2 data, no code change
2. Sequence logic in `task_manager.gd` + GUT tests (TDD first)
3. `balance.json` — `bug_spiral_threshold: 50`, `win_goal: 10000`

---

## Files Touched

- `data/tasks.json` (new)
- `autoloads/task_manager.gd`
- `data/balance.json`
- `test/unit/test_task_manager.gd`
