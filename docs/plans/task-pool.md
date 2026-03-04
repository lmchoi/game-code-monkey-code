# Task Pool — Feature Plan

The current build has 3 fixed tutorial tasks that recycle on the last one. Every run is identical and the difficulty curve never builds. This feature replaces the recycling behaviour with a proper random task pool, making runs feel different and enabling the intended progression.

---

## What's Already Built

- `data/tutorial_tasks.json` — 3 fixed tasks, sequential, hold on last
- `task_manager.gd` — loads tutorial tasks, advances by index, holds on last
- `TaskManager.reset()` — resets index to 0, progress to 0, assigns task 0

---

## What Needs Building

### 1 — `data/tasks.json` — the pool

A separate file from `tutorial_tasks.json`. Tutorial tasks stay fixed and sequential — the pool is drawn from after them.

Each task needs one new field: `tier` (1 = early, 2 = mid, 3 = late).

```json
[
  { "title": "Rename a variable to fix the bug", "complexity": 1, "deadline_days": 4, "tier": 1 },
  { "title": "Add a loading spinner to the dashboard", "complexity": 1, "deadline_days": 3, "tier": 1 },
  { "title": "Write unit tests for code that can't be tested", "complexity": 2, "deadline_days": 4, "tier": 1 },
  { "title": "Migrate the database. No rollback plan.", "complexity": 2, "deadline_days": 3, "tier": 2 },
  { "title": "Rebuild the auth system over the weekend", "complexity": 3, "deadline_days": 3, "tier": 2 },
  { "title": "Estimate the rewrite. In story points.", "complexity": 2, "deadline_days": 2, "tier": 2 },
  { "title": "Make the app GDPR compliant by Monday", "complexity": 3, "deadline_days": 2, "tier": 3 },
  { "title": "Fix prod. It's been down for 40 minutes.", "complexity": 3, "deadline_days": 1, "tier": 3 },
  { "title": "Reduce load time by 80%. No new infra budget.", "complexity": 3, "deadline_days": 2, "tier": 3 }
]
```

Aim for ~5 tasks per tier. The titles above are a starting point — tune for tone and variety.

**This commit is data-only. No code change, no functional change.**

### 2 — Pool draw logic in `task_manager.gd`

After the tutorial (once `_current_index` would exceed `_tasks.size() - 1`), draw randomly from `_pool` filtered to eligible tiers.

**Tier unlock thresholds** live in `balance.json`:

```json
"tier2_unlock_tasks": 3,
"tier3_unlock_tasks": 6
```

These are the number of tasks shipped (tutorial + pool) needed to unlock each tier. Starting values — tune via playtesting.

**Repeat draws:** allowed. Pool is large enough for a 15-min run and tracking exhaustion adds complexity for little gain. Seed is not fixed — every run is different.

**Draw logic (pseudocode):**
```
eligible = pool.filter(t => t.tier <= unlocked_tier(tasks_shipped))
pick randomly from eligible
```

`tasks_shipped` is tracked in `GameManager` (needed for endings too — same var).

**`reset()` update:** no new state to reset — draw is stateless (random each time).

### 3 — Balance tuning

With the current values, the bug spiral is unreachable in normal play:
- `ship_minimum_progress = 50` → max 5 bugs per ship
- `bug_spiral_threshold = 100` → needs 20 ships to spiral

Recommended starting values for playtesting:

```json
"bug_spiral_threshold": 50
```

That makes the spiral reachable in ~10 bad ships — achievable in a real run without deliberate grinding. Tune further after playtesting.

---

## GUT Tests (TDD for draw logic)

Write before implementing commit 2:

- Draw only returns tier 1 tasks when `tasks_shipped < tier2_unlock_tasks`
- Draw returns tier 1 + 2 tasks when `tasks_shipped >= tier2_unlock_tasks`
- Draw returns all tiers when `tasks_shipped >= tier3_unlock_tasks`
- Draw never returns an empty result (pool always has eligible tasks)

---

## Open Questions

- **How many tasks per tier?** 5 is the starting target. If runs feel repetitive after 10+ plays, add more. Pure data change.
- **Tier unlock thresholds** — `3` and `6` are guesses. Tune via playtesting (`balance.json` only).
- **Task titles** — need enough variety and tone that back-to-back repeats don't feel wrong. Write ~8 per tier to give the random draw room.
- **Does complexity need to scale within tiers?** Current approach: tier 1 = complexity 1-2, tier 2 = complexity 2-3, tier 3 = complexity 3. Hardcoded via data, not logic.

---

## Suggested Commit Order

1. `data/tasks.json` — pool data, no code change
2. Pool draw logic in `task_manager.gd` + GUT tests (TDD first)
3. `balance.json` — lower `bug_spiral_threshold` to 50, add tier unlock thresholds

---

## Files Touched

- `data/tasks.json` (new)
- `autoloads/task_manager.gd`
- `data/balance.json`
- `test/unit/test_task_manager.gd`
