#!/usr/bin/env python3
"""
Analyze logs/game.log and summarise each real gameplay run.
Test runs (multiple game_over events) are filtered out automatically.

After analyzing, key metrics for each new run are appended to
logs/metrics.jsonl. Balance notes are computed from that file.
"""

import argparse
import json
import sys
from collections import defaultdict
from pathlib import Path

DEFAULT_LOG_PATH = Path(__file__).parent.parent / "logs" / "game.log"
DEFAULT_METRICS_PATH = Path(__file__).parent.parent / "logs" / "metrics.jsonl"


def load_runs(path):
    runs = defaultdict(list)
    if not Path(path).exists():
        return runs
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
    return len([e for e in events if e.get("event") == "game_over"]) == 1


def extract_metrics(run_id, events):
    game_over = next((e for e in events if e.get("event") == "game_over"), {})
    actions = [e for e in events if e.get("event") == "action"]
    ships = [a for a in actions if a.get("action") == "ship"]
    return {
        "run_id": run_id,
        "outcome": game_over.get("outcome"),
        "day": game_over.get("day"),
        "money": game_over.get("money"),
        "bugs": game_over.get("bugs"),
        "strikes": game_over.get("strikes"),
        "work_count": sum(1 for a in actions if a.get("action") == "work"),
        "ship_count": len(ships),
        "hustle_count": sum(1 for a in actions if a.get("action") == "hustle"),
        "detection_count": len([e for e in events if e.get("event") == "detected"]),
        "auto_strike_count": len([e for e in events if e.get("event") == "auto_strike"]),
        "sloppy_ship_count": sum(1 for s in ships if s.get("bugs_added", 0) > 0),
        "total_bugs_added": sum(s.get("bugs_added", 0) for s in ships),
        "task_count": len(dict.fromkeys(a["task"] for a in actions if "task" in a)),
    }


def load_metrics(metrics_path):
    metrics_path = Path(metrics_path)
    if not metrics_path.exists():
        return {}
    metrics = {}
    with open(metrics_path) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    m = json.loads(line)
                    metrics[m["run_id"]] = m
                except (json.JSONDecodeError, KeyError):
                    pass
    return metrics


def save_metrics(metrics_path, new_metrics_by_run):
    known = load_metrics(metrics_path)
    with open(metrics_path, "a") as f:
        for run_id, m in new_metrics_by_run.items():
            if run_id not in known:
                f.write(json.dumps(m) + "\n")


def format_run(m):
    lines = [f"run {m['run_id']}"]
    lines.append(
        f"  outcome:  {m['outcome']}  |  day {m['day']}"
        f"  |  ${m['money']}  |  {m['bugs']} bugs  |  {m['strikes']} strikes"
    )
    lines.append(
        f"  actions:  {m['work_count']} work  /  {m['ship_count']} ship  /  {m['hustle_count']} hustle"
    )
    if m["detection_count"]:
        lines.append(f"  detected: {m['detection_count']}x")
    if m["auto_strike_count"]:
        lines.append(f"  overdue:  {m['auto_strike_count']} auto-strike(s)")
    if m["sloppy_ship_count"]:
        lines.append(f"  sloppy:   {m['sloppy_ship_count']} ship(s)  |  {m['total_bugs_added']} bugs added")
    lines.append(f"  tasks:    {m['task_count']}")
    return "\n".join(lines)


def balance_notes(all_metrics):
    total = len(all_metrics)
    if total == 0:
        return "\n--- no metrics found ---"
    wins = [m for m in all_metrics if m["outcome"] == "win"]
    spirals = sum(1 for m in all_metrics if m["outcome"] == "bug_spiral")

    lines = ["\n--- balance notes ---"]
    lines.append(f"  real runs:        {total}")
    lines.append(f"  bug spiral runs:  {spirals} / {total}")
    if wins:
        avg_day = sum(m["day"] for m in wins) / len(wins)
        avg_bugs = sum(m["bugs"] for m in wins) / len(wins)
        day_range = f"{min(m['day'] for m in wins)}–{max(m['day'] for m in wins)}"
        bug_range = f"{min(m['bugs'] for m in wins)}–{max(m['bugs'] for m in wins)}"
        lines.append(f"  avg win day:      {avg_day:.1f}  (range {day_range})")
        lines.append(f"  avg bugs at win:  {avg_bugs:.1f}  (range {bug_range})")
    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Analyze game logs.")
    parser.add_argument("--log", type=str, default=str(DEFAULT_LOG_PATH), help="Path to game.log")
    parser.add_argument("--metrics", type=str, default=str(DEFAULT_METRICS_PATH), help="Path to metrics.jsonl")
    parser.add_argument("--all", action="store_true", help="Show all new runs instead of just the last one")
    args = parser.parse_args()

    log_path = Path(args.log)
    metrics_path = Path(args.metrics)

    if not log_path.exists():
        print(f"no log found at {log_path}")
        sys.exit(1)

    runs = load_runs(log_path)
    real = {rid: events for rid, events in runs.items() if is_real_run(events)}

    if not real:
        print("no real gameplay runs found (only test noise or empty log)")
        sys.exit(0)

    new_metrics = {rid: extract_metrics(rid, events) for rid, events in real.items()}
    save_metrics(metrics_path, new_metrics)

    all_metrics = list(load_metrics(metrics_path).values())
    sorted_metrics = sorted(new_metrics.items())
    to_show = sorted_metrics if args.all else [sorted_metrics[-1]]

    for rid, _ in to_show:
        print(format_run(new_metrics[rid]))
        print()

    print(balance_notes(all_metrics))


if __name__ == "__main__":
    main()
