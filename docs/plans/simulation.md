# Strategy Simulation — Idea

Run hypothetical strategies through the game engine headlessly to understand balance without manual playtesting. "What happens if the player hustles every single day?" — run it 1000 times and find out.

---

## Goal

- Test strategies (always hustle, always work, hybrid) and get outcome distributions
- Understand how balance changes affect a given strategy
- Complement logging — simulation output goes through the same log, giving a trace to analyse

---

## Approach

A standalone GDScript run with `godot --headless --script` that:

1. Instantiates GameManager + TaskManager
2. Defines a strategy as a callable: `func(state: Dictionary) -> String`
3. Loops: call strategy → call `do_work/do_hustle/do_ship` → check for `game_over`
4. Resets and repeats N times
5. Summary printed to stdout; detailed trace written to `user://game.log` via the logging system

### Strategy interface

```gdscript
# "Always hustle" strategy
func always_hustle(state: Dictionary) -> String:
    return "hustle"

# "Work until 80% progress then ship"
func work_then_ship(state: Dictionary) -> String:
    if state.progress >= 80.0:
        return "ship"
    return "work"
```

State dict passed to strategy: `{ day, bugs, money, progress, strikes, task_overdue }`.

### Example output

```
Ran 1000 simulations of "always_hustle"
  win:        12%
  bug_spiral:  4%
  fired:      84%
  avg days:   8.3
```

---

## Prerequisites

Before the sim script can work, three things need to change in GameManager:

1. **Seedable RNG** — replace global `randf()` in `_hustle_detection` with a `RandomNumberGenerator` instance so runs can be seeded for determinism (or just run Monte Carlo without seeding).
2. **Full reset** — `reset()` must also reset TaskManager (current task, progress, pool position).
3. **Balance loading outside `_ready()`** — move `balance.json` loading so it works when GameManager is instantiated in a headless script (not via the scene tree).

---

## Dependencies

- Logging (logging.md) — sim output is only useful if it's captured. Build logging first.
- The three GameManager prerequisites above.
