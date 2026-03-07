import unittest
import json
import tempfile
import os
from pathlib import Path
from unittest.mock import patch, mock_open

# Import the functions from the script
import sys
sys.path.append(str(Path(__file__).parent.parent.parent / "scripts"))
from analyze_log import load_runs, is_real_run, extract_metrics, load_metrics, balance_notes

class TestAnalyzeLog(unittest.TestCase):
    def test_load_runs(self):
        log_content = (
            '{"run_id": "run1", "event": "start"}\n'
            '{"run_id": "run1", "event": "action", "action": "work"}\n'
            '{"run_id": "run2", "event": "start"}\n'
            'invalid json\n'
            '{"no_run_id": "data"}\n'
        )
        with patch("builtins.open", mock_open(read_data=log_content)):
            with patch("pathlib.Path.exists", return_value=True):
                runs = load_runs("dummy_path")
                self.assertEqual(len(runs), 2)
                self.assertEqual(len(runs["run1"]), 2)
                self.assertEqual(len(runs["run2"]), 1)

    def test_is_real_run(self):
        self.assertTrue(is_real_run([{"event": "game_over"}]))
        self.assertFalse(is_real_run([]))
        self.assertFalse(is_real_run([{"event": "game_over"}, {"event": "game_over"}]))

    def test_extract_metrics(self):
        events = [
            {"run_id": "run1", "event": "action", "action": "work", "task": "t1"},
            {"run_id": "run1", "event": "action", "action": "ship", "task": "t1", "bugs_added": 2},
            {"run_id": "run1", "event": "action", "action": "hustle", "task": "t2"},
            {"run_id": "run1", "event": "detected"},
            {"run_id": "run1", "event": "auto_strike"},
            {"run_id": "run1", "event": "game_over", "outcome": "win", "day": 5, "money": 100, "bugs": 1, "strikes": 0}
        ]
        metrics = extract_metrics("run1", events)
        self.assertEqual(metrics["run_id"], "run1")
        self.assertEqual(metrics["outcome"], "win")
        self.assertEqual(metrics["day"], 5)
        self.assertEqual(metrics["money"], 100)
        self.assertEqual(metrics["work_count"], 1)
        self.assertEqual(metrics["ship_count"], 1)
        self.assertEqual(metrics["hustle_count"], 1)
        self.assertEqual(metrics["detection_count"], 1)
        self.assertEqual(metrics["auto_strike_count"], 1)
        self.assertEqual(metrics["sloppy_ship_count"], 1)
        self.assertEqual(metrics["total_bugs_added"], 2)
        self.assertEqual(metrics["task_count"], 2)

    def test_load_metrics(self):
        metrics_content = (
            '{"run_id": "run1", "outcome": "win"}\n'
            '{"run_id": "run2", "outcome": "lose"}\n'
        )
        with patch("builtins.open", mock_open(read_data=metrics_content)):
            with patch("pathlib.Path.exists", return_value=True):
                metrics = load_metrics("dummy_metrics_path")
                self.assertEqual(len(metrics), 2)
                self.assertEqual(metrics["run1"]["outcome"], "win")

    def test_balance_notes(self):
        all_metrics = [
            {"outcome": "win", "day": 10, "bugs": 2},
            {"outcome": "win", "day": 12, "bugs": 4},
            {"outcome": "bug_spiral", "day": 5, "bugs": 10},
        ]
        notes = balance_notes(all_metrics)
        self.assertIn("real runs:        3", notes)
        self.assertIn("bug spiral runs:  1 / 3", notes)
        self.assertIn("avg win day:      11.0", notes)
        self.assertIn("avg bugs at win:  3.0", notes)

    def test_balance_notes_empty(self):
        notes = balance_notes([])
        self.assertIn("no metrics found", notes)

if __name__ == "__main__":
    unittest.main()
