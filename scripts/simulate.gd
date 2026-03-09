extends SceneTree

const N_RUNS = 1000

var _gm: Node
var _tm: Node
var _ran: bool = false
var _current_run_grades: Array = []
var _trace_mode: bool = false

func _process(_delta: float) -> bool:
	if _ran:
		return false
	_ran = true

	_gm = get_root().get_node("GameManager")
	_tm = get_root().get_node("TaskManager")
	_gm.review_ready.connect(_on_review)

	var strategies = {
		"always_hustle": always_hustle,
		"diligent_worker": diligent_worker,
		"ship_asap": ship_asap,
		"hustle_then_ship": hustle_then_ship,
		"hustle_ship_asap": hustle_ship_asap,
	}

	var args = OS.get_cmdline_user_args()
	if args.size() > 0:
		var strategy_name = args[0]
		if not strategies.has(strategy_name):
			print("Unknown strategy: %s. Available: %s" % [strategy_name, ", ".join(strategies.keys())])
			quit(1)
			return false
		run_trace(strategy_name, strategies[strategy_name])
	else:
		get_root().get_node("GameLogger").enabled = false
		for name in strategies:
			print_results(name, run_strategy(strategies[name], N_RUNS))

	quit()
	return false

func get_state() -> Dictionary:
	return {
		"day": _gm.day,
		"bugs": _gm.bugs,
		"money": _gm.money,
		"progress": _tm.current_progress,
		"strikes": _gm.strikes,
		"task_overdue": _gm.task_overdue,
		"can_ship": _tm.current_progress >= _gm.balance.ship_minimum_progress,
		"deadline_day": _tm.current_task["deadline_day"],
	}

func _on_review() -> void:
	var grades = {
		"quality": _gm.calculate_quality_grade(),
		"output": _gm.calculate_output_grade(),
		"timeliness": _gm.calculate_timeliness_grade(),
		"bugs": _gm.bugs,
	}
	if _trace_mode:
		print("  --- period %d review ---  Quality: %s  Output: %s  Timeliness: %s  bugs=%d  on_pip=%s" % [
			_current_run_grades.size() + 1,
			grades.quality, grades.output, grades.timeliness, grades.bugs, _gm.on_pip])
	_gm.apply_review_outcome()
	_current_run_grades.append(grades)

func run_strategy(strategy: Callable, n: int) -> Dictionary:
	var tally = {}
	var win_days: Array = []
	var win_bugs: Array = []
	var win_strikes: Array = []
	var all_days: Array = []
	var all_tasks: Array = []
	var days_per_outcome = {} # outcome -> Array
	var bugs_per_outcome = {} # outcome -> Array

	var grade_tally: Dictionary = {}
	var bugs_per_period: Dictionary = {}  # "p1" -> Array, "p2" -> Array

	for _i in n:
		_current_run_grades = []
		_gm.reset()
		var safety = 0
		while _gm.game_over_reason == "" and safety < 1000:
			match strategy.call(get_state()):
				"work":   _gm.do_work()
				"ship":   _gm.do_ship()
				"hustle": _gm.do_hustle()
			safety += 1
		var outcome = _gm.game_over_reason if _gm.game_over_reason != "" else "timeout"
		tally[outcome] = tally.get(outcome, 0) + 1
		all_days.append(_gm.day)
		all_tasks.append(_gm.tasks_shipped)

		for period_idx in _current_run_grades.size():
			var p = period_idx + 1
			var snap = _current_run_grades[period_idx]
			var pkey = "p%d" % p
			if not bugs_per_period.has(pkey):
				bugs_per_period[pkey] = []
			bugs_per_period[pkey].append(snap["bugs"])
			for metric in snap:
				if metric == "bugs":
					continue
				var key = "p%d_%s" % [p, metric]
				if not grade_tally.has(key):
					grade_tally[key] = {}
				grade_tally[key][snap[metric]] = grade_tally[key].get(snap[metric], 0) + 1

		if not days_per_outcome.has(outcome):
			days_per_outcome[outcome] = []
		days_per_outcome[outcome].append(_gm.day)
		if not bugs_per_outcome.has(outcome):
			bugs_per_outcome[outcome] = []
		bugs_per_outcome[outcome].append(_gm.bugs)

		if outcome == "win":
			win_days.append(_gm.day)
			win_bugs.append(_gm.bugs)
			win_strikes.append(_gm.strikes)

	tally["_grades"] = grade_tally
	tally["_bugs_per_period"] = bugs_per_period
	tally["_bugs_per_outcome"] = bugs_per_outcome
	
	if all_days.size() > 0:
		tally["_avg_day"] = all_days.reduce(func(a, b): return a + b, 0.0) / all_days.size()
		tally["_avg_tasks"] = all_tasks.reduce(func(a, b): return a + b, 0.0) / all_tasks.size()
		
	for outcome in days_per_outcome:
		var ds = days_per_outcome[outcome]
		tally["_avg_day_" + outcome] = ds.reduce(func(a, b): return a + b, 0.0) / ds.size()
		
	if win_days.size() > 0:
		tally["_win_avg_day"] = win_days.reduce(func(a, b): return a + b, 0.0) / win_days.size()
		tally["_win_avg_bugs"] = win_bugs.reduce(func(a, b): return a + b, 0.0) / win_bugs.size()
		tally["_win_avg_strikes"] = win_strikes.reduce(func(a, b): return a + b, 0.0) / win_strikes.size()
		tally["_win_days"] = win_days
	return tally

func run_trace(strategy_name: String, strategy: Callable) -> void:
	print("=== trace: %s ===" % strategy_name)
	_trace_mode = true
	_current_run_grades = []
	_gm.reset()
	var safety = 0
	while _gm.game_over_reason == "" and safety < 500:
		var state = get_state()
		var action = strategy.call(state)
		print("day=%d  bugs=%d  money=%d  progress=%.0f  strikes=%d  overdue=%s  -> %s" % [
			state.day, state.bugs, state.money, state.progress,
			state.strikes, state.task_overdue, action])
		match action:
			"work":   _gm.do_work()
			"ship":   _gm.do_ship()
			"hustle": _gm.do_hustle()
		safety += 1
	var outcome = _gm.game_over_reason if _gm.game_over_reason != "" else "timeout"
	print("=== outcome: %s ===" % outcome)

func print_results(name: String, tally: Dictionary) -> void:
	var outcome_keys = tally.keys().filter(func(k): return not k.begins_with("_"))
	var n = outcome_keys.reduce(func(a, b): return a + tally[b], 0)
	
	print("\n%s (n=%d):" % [name, n])
	print("  Ending Type Breakdown:")
	var bugs_per_outcome: Dictionary = tally.get("_bugs_per_outcome", {})
	for outcome in outcome_keys:
		var avg_day = tally.get("_avg_day_" + outcome, 0.0)
		var bugs_arr: Array = bugs_per_outcome.get(outcome, [])
		var avg_bugs = bugs_arr.reduce(func(a, b): return a + b, 0.0) / max(1, bugs_arr.size())
		print("    %-20s %d%% (avg day %.1f  avg bugs %.0f)" % [outcome + ":", roundi(100.0 * tally[outcome] / n), avg_day, avg_bugs])
	
	if tally.has("_avg_tasks"):
		print("  avg tasks completed: %.1f" % tally["_avg_tasks"])

	if tally.has("_win_avg_day"):
		print("  avg win day:         %.1f" % tally["_win_avg_day"])
		print("  avg win bugs:        %.1f" % tally["_win_avg_bugs"])
		print("  avg win strikes:     %.1f" % tally["_win_avg_strikes"])
		var days: Array = tally["_win_days"]
		var min_day = days.reduce(func(a, b): return min(a, b))
		var max_day = days.reduce(func(a, b): return max(a, b))
		const BUCKETS = 10
		var bucket_size = max(1, ceili(float(max_day - min_day + 1) / BUCKETS))
		var counts = {}
		for d in days:
			var bucket = min_day + (int(d - min_day) / bucket_size) * bucket_size
			counts[bucket] = counts.get(bucket, 0) + 1
		print("  win day distribution:")
		for bucket in counts:
			var bar = "#".repeat(roundi(20.0 * counts[bucket] / days.size()))
			print("    day %3d-%3d  %s (%d%%)" % [bucket, bucket + bucket_size - 1, bar, roundi(100.0 * counts[bucket] / days.size())])

	var grade_tally: Dictionary = tally.get("_grades", {})
	const METRICS = ["quality", "output", "timeliness"]
	const LABELS = ["Exceeds Expectations", "Meets Expectations", "Needs Improvement"]
	const SHORT = {"Exceeds Expectations": "Exceeds", "Meets Expectations": "Meets", "Needs Improvement": "Needs"}
	for p in [1, 2]:
		var has_period = false
		for metric in METRICS:
			if grade_tally.has("p%d_%s" % [p, metric]):
				has_period = true
				break
		if not has_period:
			continue
		var period_total = 0
		var first_metric = grade_tally.get("p%d_%s" % [p, METRICS[0]], {})
		for v in first_metric.values():
			period_total += v
		var bugs_arr: Array = tally.get("_bugs_per_period", {}).get("p%d" % p, [])
		var avg_bugs_str = ""
		if bugs_arr.size() > 0:
			var avg_b = bugs_arr.reduce(func(a, b): return a + b, 0.0) / bugs_arr.size()
			avg_bugs_str = "  avg bugs: %.0f" % avg_b
		print("  review grades (period %d, n=%d):%s" % [p, period_total, avg_bugs_str])
		for metric in METRICS:
			var counts_m: Dictionary = grade_tally.get("p%d_%s" % [p, metric], {})
			var parts = []
			for label in LABELS:
				var cnt = counts_m.get(label, 0)
				parts.append("%s %d%%" % [SHORT[label], roundi(100.0 * cnt / period_total)])
			print("    %-12s %s" % [metric + ":", "  ".join(parts)])

# Strategies
func always_hustle(_state: Dictionary) -> String:
	return "hustle"

func diligent_worker(state: Dictionary) -> String:
	if state.progress >= 100.0 or (state.task_overdue and state.can_ship):
		return "ship"
	return "work"

func ship_asap(state: Dictionary) -> String:
	if state.can_ship:
		return "ship"
	return "work"

func hustle_then_ship(state: Dictionary) -> String:
	if state.can_ship and state.day >= state.deadline_day:
		return "ship"
	if not state.task_overdue:
		return "hustle"
	return "work"

func hustle_ship_asap(state: Dictionary) -> String:
	if state.can_ship and state.day >= state.deadline_day:
		return "ship"
	if state.can_ship:
		return "hustle"  # hit minimum progress, hustle until deadline
	return "work"
