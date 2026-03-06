Analyze the game log and report on real gameplay runs.

Steps:
1. Run `python3 scripts/analyze_log.py` from the project root (shows last run only; pass `--all` to see every run)
2. Read the output and report it clearly, noting any balance concerns
3. Commit `logs/metrics.jsonl` if it has new entries: `git add logs/metrics.jsonl && git commit -m "chore: update metrics from gameplay runs"`
