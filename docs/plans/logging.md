# Structured Logging — Idea

Persist a structured log of game events to disk so we can understand what happened during a run — both in real play and in simulation.

---

## Goal

Answer questions like:
- What actions did the player take, and in what order?
- At what bug count do runs typically end?
- How often does hustling lead to detection?
- What was progress at ship time?

---

## Approach

Write one JSON line per event to `user://game.log` as events happen (not batched on game over). Each run continues appending to the same file — the log accumulates across sessions.

Include a `run_id` (timestamp or incrementing int) on every line so runs can be grouped in analysis.

### Example lines

```
{"run_id": 1, "event": "action", "day": 1, "action": "work", "bugs": 0, "money": 0, "progress_before": 0.0, "progress_after": 12.5, "task": "blockchain_todo"}
{"run_id": 1, "event": "action", "day": 2, "action": "hustle", "bugs": 0, "money": 200, "detected": false, "strikes": 0}
{"run_id": 1, "event": "action", "day": 3, "action": "ship", "bugs": 2, "progress_at_ship": 74.2, "task": "blockchain_todo"}
{"run_id": 1, "event": "game_over", "day": 14, "outcome": "win", "money": 5200, "bugs": 3, "strikes": 1}
```

### Log location

`user://game.log` resolves to `~/Library/Application Support/Godot/app_userdata/Code Monkey/game.log` on macOS.

---

## Implementation Notes

### Logger autoload (swappable backend)

Logging calls go through a dedicated `Logger` autoload — not directly in `GameManager`. This means the backend (JSONL file, Godot addon, remote endpoint, no-op) can be swapped without touching any game logic.

```gdscript
# autoloads/logger.gd
func log(fields: Dictionary) -> void:
    # today: write JSONL to file
    # tomorrow: call a Godot addon, send to remote, or no-op
```

`GameManager` (and the future sim script) only ever calls `Logger.log(fields)`. Nothing else needs to change when the backend changes.

### Other notes

- `run_id` injected automatically by Logger on every line — set from `Time.get_unix_time_from_system()` at run start
- Call `Logger.log()` from `do_work`, `do_hustle`, `do_ship`, and wherever `game_over` is emitted
- No test needed for the file I/O itself — keep it simple

---

## Analysis

Parse with Python + `jq`. Example:

```bash
# All game over outcomes
jq 'select(.event == "game_over") | .outcome' game.log | sort | uniq -c

# Average day of hustle detection
jq 'select(.event == "action" and .action == "hustle" and .detected == true) | .day' game.log | awk '{sum+=$1; n++} END {print sum/n}'
```

---

## Dependencies

None — can be built standalone. Useful immediately for real play, and will also capture simulation output for free once simulation is built.
