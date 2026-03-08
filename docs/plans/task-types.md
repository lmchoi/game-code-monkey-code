# Task Types — Feature Plan

**Status:** 💡 Idea

Add a `type` field to tasks in `data/tasks.json`. Each type has a distinct mechanical consequence
on ship, teaching new rules gradually across the tier progression.

---

## Goal

Tier1 tasks are generic — the player learns the basic loop. Tier2 tasks introduce types that
create new tradeoffs. Tier3 (impossible deadlines) then feels like a natural escalation of
rules already understood.

---

## Task Types

| Type | Mechanic |
|------|----------|
| `standard` | Existing behaviour. No change. |
| `high_visibility` | Sloppy ship triggers an immediate strike instead of just bugs. Raises stakes on quality decisions. |
| `legacy` | On ship (any quality), reduce current bug count by a fixed amount. Rewards clean play; gives a reason to manage bugs proactively. |
| `bonus` | Short deadline, but awards a cash bonus on ship (regardless of quality). Teaches the crunch tradeoff early. |

---

## Implementation

### data/tasks.json

Add `"type"` field to each task. Tier1 tasks are all `"standard"`. Tier2 and tier3 tasks use the new types.

```json
{ "title": "...", "complexity": 3, "deadline_days": 4, "type": "high_visibility" }
```

### game_manager.gd — do_ship()

Read `current_task["type"]` and apply the consequence after the existing ship logic:

```gdscript
match current_task.get("type", "standard"):
    "high_visibility":
        if was_sloppy:
            strikes += 1
            # existing bug logic still runs
    "legacy":
        bugs = max(0, bugs - balance.get("legacy_bug_reduction", 5))
    "bonus":
        money += balance.get("bonus_task_reward", 300)
```

### balance.json

```json
"legacy_bug_reduction": 5,
"bonus_task_reward": 300
```

### GUT Tests

- `high_visibility` sloppy ship adds a strike
- `high_visibility` clean ship does not add a strike
- `legacy` ship reduces bug count
- `legacy` ship does not reduce below 0
- `bonus` ship adds cash reward
- `standard` ship behaviour unchanged

---

## Dependencies

- Task pool tier sequence — already built
- Review grades (mechanical consequences) — parallel; task types don't depend on grades

---

## Suggested Commit Order

1. Add `type` field to all tasks in `data/tasks.json` (data only)
2. `do_ship()` type dispatch in `game_manager.gd` + GUT tests (TDD)
3. `balance.json` — `legacy_bug_reduction`, `bonus_task_reward`
