#!/usr/bin/env python3
"""
Analyze logs/game.log and summarise each real gameplay run.
Test runs (multiple game_over events) are filtered out automatically.
"""

import json
import sys
from collections import defaultdict
from pathlib import Path

LOG_PATH = Path(__file__).parent.parent / "logs" / "game.log"


def load_runs(path):
    runs = defaultdict(list)
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                e = json.loads(line)
                runs[e["run_id"]].append(e)
            except (json.JSONDecodeError, KeyError):
                pass
    return runs


def is_real_run(events):
    game_overs = [e for e in events if e.get("event") == "game_over"]
    return len(game_overs) == 1


def summarise_run(run_id, events):
    game_over = next((e for e in events if e.get("event") == "game_over"), None)
    actions = [e for e in events if e.get("event") == "action"]
    detections = [e for e in events if e.get("event") == "detected"]
    auto_strikes = [e for e in events if e.get("event") == "auto_strike"]

    work_count = sum(1 for a in actions if a.get("action") == "work")
    ship_count = sum(1 for a in actions if a.get("action") == "ship")
    hustle_count = sum(1 for a in actions if a.get("action") == "hustle")

    ships = [a for a in actions if a.get("action") == "ship"]
    sloppy_ships = [s for s in ships if s.get("bugs_added", 0) > 0]
    total_bugs_added = sum(s.get("bugs_added", 0) for s in ships)

    tasks_seen = list(dict.fromkeys(
        a["task"] for a in actions if "task" in a
    ))

    lines = []
    lines.append(f"run {run_id}")
    if game_over:
        lines.append(
            f"  outcome:  {game_over['outcome']}  |  day {game_over['day']}"
            f"  |  ${game_over['money']}  |  {game_over['bugs']} bugs"
            f"  |  {game_over['strikes']} strikes"
        )
    lines.append(
        f"  actions:  {work_count} work  /  {ship_count} ship  /  {hustle_count} hustle"
    )
    if detections:
        lines.append(f"  detected: {len(detections)}x  (strikes at: {[d['strikes'] for d in detections]})")
    if auto_strikes:
        lines.append(f"  overdue:  {len(auto_strikes)} auto-strike(s)")
    if sloppy_ships:
        lines.append(
            f"  sloppy:   {len(sloppy_ships)} ship(s) below 100%"
            f"  |  {total_bugs_added} bugs added total"
        )
    lines.append(f"  tasks:    {len(tasks_seen)} unique  —  {tasks_seen[0]} ... {tasks_seen[-1]}" if len(tasks_seen) > 1 else f"  tasks:    {tasks_seen}")
    return "\n".join(lines)


def balance_notes(real_runs_events):
    bug_spiral_runs = sum(
        1 for events in real_runs_events
        if any(e.get("outcome") == "bug_spiral" for e in events if e.get("event") == "game_over")
    )
    win_runs = [
        events for events in real_runs_events
        if any(e.get("outcome") == "win" for e in events if e.get("event") == "game_over")
    ]
    if win_runs:
        win_days = [
            next(e["day"] for e in events if e.get("event") == "game_over")
            for events in win_runs
        ]
        avg_win_day = sum(win_days) / len(win_days)
        max_bugs_in_wins = [
            next(e["bugs"] for e in events if e.get("event") == "game_over")
            for events in win_runs
        ]
        avg_bugs = sum(max_bugs_in_wins) / len(max_bugs_in_wins)

    lines = ["\n--- balance notes ---"]
    lines.append(f"  real runs:       {len(real_runs_events)}")
    lines.append(f"  bug spiral wins: {bug_spiral_runs} / {len(real_runs_events)}")
    if win_runs:
        lines.append(f"  avg win day:     {avg_win_day:.1f}  (range {min(win_days)}–{max(win_days)})")
        lines.append(f"  avg bugs at win: {avg_bugs:.1f}  (range {min(max_bugs_in_wins)}–{max(max_bugs_in_wins)})")
    return "\n".join(lines)


def main():
    if not LOG_PATH.exists():
        print(f"no log found at {LOG_PATH}")
        sys.exit(1)

    runs = load_runs(LOG_PATH)
    real = {rid: events for rid, events in runs.items() if is_real_run(events)}

    if not real:
        print("no real gameplay runs found (only test noise or empty log)")
        sys.exit(0)

    for rid, events in sorted(real.items()):
        print(summarise_run(rid, events))
        print()

    print(balance_notes(list(real.values())))


if __name__ == "__main__":
    main()
