# Fired / PIP System — Feature Plan

Currently, the player only gets fired if they are caught HUSTLING 3 times. This plan adds "Fired for Overdue" and fleshes out the Strike/PIP (Performance Improvement Plan) system to make the corporate pressure feel real.

---

## What's Already Built

- `strikes` variable in `GameManager` (0–3).
- `StrikeLabel` in `TopBar` showing `⚠️ N`.
- HUSTLE detection logic (base chance + overdue bonus + strike bonuses).
- `game_over.emit("fired_hustle")` when strikes hit 3 via hustle detection.

---

## What Needs Building

### 1 — Overdue tracking

Track how many days the current task has been overdue.

| Var | Type | Description |
|-----|------|-------------|
| `overdue_days` | int | Incremented in `GameManager` at end of day if `task_overdue` is true. Reset on new task. |

**Logic:**
In `GameManager._do_bookkeeping()`:
```gdscript
if task_overdue:
    overdue_days += 1
else:
    overdue_days = 0
```

### 2 — Fired for Overdue (The PIP Trap)

Missing deadlines climbs the same Warning → PIP → Fired ladder as getting caught hustling.

**New Balance Values (`balance.json`):**
- `max_overdue_days`: 3 (Days overdue before a strike is auto-issued and the counter resets).

**Logic:**
In `GameManager._check_game_state()`:
```gdscript
if overdue_days >= int(balance.max_overdue_days):
    strikes += 1
    overdue_days = 0
    if strikes >= int(balance.max_strikes):
        game_over.emit("fired_overdue")
```

### 3 — Strike Terminology & UI

Make the strikes feel like corporate disciplinary actions.

| Strikes | Name | Effect |
|---------|------|--------|
| 1 | **Warning** | Boss is watching. Detection chance +10%. |
| 2 | **PIP** | Performance Improvement Plan. Detection chance +20%. Deadline firing active. |
| 3 | **Terminated** | Immediate game over. |

**UI Update:**
Update `StrikeLabel` to show the name:
- `⚠️ 1 (Warning)`
- `⚠️ 2 (PIP)`

### 4 — Distinct Endings

Distinguish between being caught "cheating" and being fired for "incompetence".

**New Ending (`data/endings.json`):**
- `CAUGHT RED-HANDED`: Triggered by `reason == "fired_hustle"`. Quote: "Security will escort you out."
- `TERMINATED FOR CAUSE`: Triggered by `reason == "fired_overdue"`. Quote: "Your performance did not meet expectations."

Update `endings.md` (or the implementation) to handle `fired_hustle` (the old `fired`) vs `fired_overdue`.

---

## GUT Tests (TDD)

Write these before implementing the logic:

- `overdue_days` increments correctly when `day > deadline_day`.
- `overdue_days` resets to 0 when a new task is assigned.
- `game_over("fired_overdue")` emits when `overdue_days >= 3` and auto-strike pushes `strikes` to `max_strikes`.
- Auto-strike is issued and `overdue_days` resets when threshold hit below `max_strikes`.

---

## Suggested Commit Order

1. **Overdue Tracking**: `overdue_days` logic in `GameManager` + GUT tests.
2. **Overdue Firing**: `fired_overdue` condition in `_check_game_state` + `balance.json` updates + GUT tests.
3. **UI Polish**: Update `StrikeLabel` with "Warning" / "PIP" labels.
4. **Endings Wiring**: Ensure recap screen distinguishes between the two firing reasons.

---

## Files Touched

- `autoloads/game_manager.gd`
- `data/balance.json`
- `scenes/game_ui.gd`
- `test/unit/test_game_manager.gd`
- `docs/plans/endings.md` (to update ending list)
