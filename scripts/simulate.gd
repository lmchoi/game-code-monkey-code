extends SceneTree

const N_RUNS = 1000

var _gm: Node
var _tm: Node
var _ran: bool = false

func _process(_delta: float) -> bool:
	if _ran:
		return false
	_ran = true

	_gm = get_root().get_node("GameManager")
	_tm = get_root().get_node("TaskManager")

	var strategies = {
		"always_hustle": always_hustle,
		"diligent_worker": diligent_worker,
		"ship_asap": ship_asap,
		"hustle_then_ship": hustle_then_ship,
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

func run_strategy(strategy: Callable, n: int) -> Dictionary:
	var tally = {}
	var win_days: Array = []
	var win_bugs: Array = []
	var win_strikes: Array = []
	for _i in n:
		_gm.reset()
		var safety = 0
		while _gm.game_over_reason == "" and safety < 500:
			match strategy.call(get_state()):
				"work":   _gm.do_work()
				"ship":   _gm.do_ship()
				"hustle": _gm.do_hustle()
			safety += 1
		var outcome = _gm.game_over_reason if _gm.game_over_reason != "" else "timeout"
		tally[outcome] = tally.get(outcome, 0) + 1
		if outcome == "win":
			win_days.append(_gm.day)
			win_bugs.append(_gm.bugs)
			win_strikes.append(_gm.strikes)
	if win_days.size() > 0:
		tally["_win_avg_day"] = win_days.reduce(func(a, b): return a + b, 0.0) / win_days.size()
		tally["_win_avg_bugs"] = win_bugs.reduce(func(a, b): return a + b, 0.0) / win_bugs.size()
		tally["_win_avg_strikes"] = win_strikes.reduce(func(a, b): return a + b, 0.0) / win_strikes.size()
		tally["_win_days"] = win_days
	return tally

func run_trace(strategy_name: String, strategy: Callable) -> void:
	print("=== trace: %s ===" % strategy_name)
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
	for outcome in outcome_keys:
		print("  %-20s %d%%" % [outcome + ":", roundi(100.0 * tally[outcome] / n)])
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

# Strategies
func always_hustle(_state: Dictionary) -> String:
	return "hustle"

func diligent_worker(state: Dictionary) -> String:
	if state.progress >= 100.0 or state.task_overdue:
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
