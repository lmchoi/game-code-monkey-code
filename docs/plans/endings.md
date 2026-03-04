# Endings System — Feature Plan

The recap screen currently shows a hardcoded "THE PRAGMATIST" for all outcomes. This doc tracks what's needed to make it real.

---

## What's Already Built

- `scenes/recap.tscn` — EndingTitleLabel, DayLabel, EndingQuoteLabel, PlayAgainButton
- `GameManager.reset()` + `TaskManager.reset()` — Play Again works
- `game_over` emits `"win"`, `"fired"`, or `"bug_spiral"`

---

## What Needs Building

### 1 — Run stat tracking

Track in `GameManager` (reset in `reset()`):

| Var | Type | Description |
|-----|------|-------------|
| `tasks_shipped` | int | incremented in `do_ship()` |
| `ships_below_60` | int | incremented in `do_ship()` when progress < 60 at ship time |
| `total_bugs_accumulated` | int | incremented whenever `bugs +=` |

### 2 — Outcome text in recap

`DayLabel` currently shows `"Day N"`. Should show outcome:
- win → `"Day N — you escaped."`
- fired → `"Day N — security escorted you out."`
- bug_spiral → `"Day N — buried in bugs."`

Store `game_over_reason: String` on `GameManager`, set it before emitting `game_over`.

### 3 — Stat labels in recap

Add to `recap.tscn` below DayLabel:
- `"You shipped N tasks. N under 60%."`
- `"N bugs followed you out."`

### 4 — `get_ending()` + endings data file

Extract titles and quotes to `data/endings.json` — not hardcoded in script.

```json
{
  "THE PERFECTIONIST": { "quote": "You escaped with your soul intact." },
  "THE PRAGMATIST":    { "quote": "You made reasonable decisions under unreasonable conditions. No one will remember." },
  "THE SPEED RUNNER":  { "quote": "You got out before they could break you." },
  "THE TECHNICAL DEBT MONSTER": { "quote": "You left a trail of destruction." },
  "THE AI PROMPT ENGINEER": { "quote": "You shipped TODO comments as features." },
  "CAUGHT RED-HANDED": { "quote": "Security will escort you out." },
  "DEATH SPIRAL":      { "quote": "100 bugs. Nothing works. Nothing ever worked." }
}
```

`get_ending()` in `GameManager` — loss endings always override, win endings first-match:

| Ending | Condition |
|--------|-----------|
| DEATH SPIRAL | reason == "bug_spiral" |
| CAUGHT RED-HANDED | reason == "fired" |
| THE PERFECTIONIST | win + total_bugs <= 10 |
| THE SPEED RUNNER | win + day <= `speed_runner_day_threshold` (balance.json) |
| THE TECHNICAL DEBT MONSTER | win + total_bugs >= 50 |
| THE AI PROMPT ENGINEER | win + ships_below_60 >= 3 |
| THE PRAGMATIST | win (fallback) |

Add `speed_runner_day_threshold` to `balance.json` — TBD via playtesting.

---

## Suggested Commit Order

1. Run stat tracking (`tasks_shipped`, `ships_below_60`, `total_bugs_accumulated`) + `game_over_reason` — logic + GUT tests
2. Outcome text in DayLabel — wire `game_over_reason` in recap
3. Stat labels in recap — UI only
4. `data/endings.json` + `get_ending()` — logic + GUT tests
5. Wire `get_ending()` into recap — replace hardcoded strings

---

## Open Questions

- See `DECISIONS.md` — `victory-endings` for trigger discussion
- `speed_runner_day_threshold` — set a starting value in balance.json, tune via playtesting
