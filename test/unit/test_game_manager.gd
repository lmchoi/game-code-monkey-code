extends GutTest

var game_manager: Node

func before_each():
	game_manager = GameManager.duplicate()
	add_child_autofree(game_manager)
	game_manager.balance = {
		"bug_penalty_per_bug": 0.01,
		"bugs_per_incomplete_percent": 0.1,
		"detection_base": 0.10,
		"detection_overdue_bonus": 0.20,
		"detection_strike1_bonus": 0.10,
		"detection_strike2_bonus": 0.20,
		"max_strikes": 3,
		"bug_spiral_threshold": 50,
		"max_overdue_days": 3,
		"win_goal": 5000,
		"payday_interval": 5,
		"salary_per_payday": 500,
	}

# === PROGRESS DELTA TESTS ===

func test_progress_delta_complexity_1_no_bugs():
	var delta = game_manager.calculate_progress_delta(1, 0)
	assert_almost_eq(delta, 100.0, 0.001, "Complexity 1, 0 bugs should complete in one WORK")

func test_progress_delta_complexity_2_no_bugs():
	var delta = game_manager.calculate_progress_delta(2, 0)
	assert_almost_eq(delta, 50.0, 0.001, "Complexity 2, 0 bugs should take two WORKs")

func test_progress_delta_complexity_1_100_bugs():
	var delta = game_manager.calculate_progress_delta(1, 100)
	assert_almost_eq(delta, 50.0, 0.001, "100 bugs should halve progress output")

# === BUG ACCUMULATION TESTS ===

func test_bugs_for_ship_at_zero_progress():
	assert_eq(game_manager.calculate_bugs_for_ship(0.0), 10, "Shipping at 0% should add 10 bugs")

func test_bugs_for_ship_at_full_progress():
	assert_eq(game_manager.calculate_bugs_for_ship(100.0), 0, "Shipping at 100% should add 0 bugs")

func test_bugs_for_ship_at_half_progress():
	assert_eq(game_manager.calculate_bugs_for_ship(50.0), 5, "Shipping at 50% should add 5 bugs")

func test_bugs_for_ship_rounds_fractional_result():
	assert_eq(game_manager.calculate_bugs_for_ship(95.0), 1, "Shipping at 95% adds 0.5 — rounds to 1, not truncates to 0")

# === DETECTION CHANCE TESTS ===

func test_detection_chance_base_only():
	assert_almost_eq(game_manager.calculate_detection_chance(0, false), 0.10, 0.001, "base only")

func test_detection_chance_overdue_adds_bonus():
	assert_almost_eq(game_manager.calculate_detection_chance(0, true), 0.30, 0.001, "overdue bonus")

func test_detection_chance_strike1_adds_bonus():
	assert_almost_eq(game_manager.calculate_detection_chance(1, false), 0.20, 0.001, "strike 1 bonus")

func test_detection_chance_strike2_adds_bonus():
	assert_almost_eq(game_manager.calculate_detection_chance(2, false), 0.30, 0.001, "strike 2 bonus")

func test_detection_chance_strike1_and_overdue():
	assert_almost_eq(game_manager.calculate_detection_chance(1, true), 0.40, 0.001, "strike 1 + overdue")

func test_detection_chance_strike2_and_overdue():
	assert_almost_eq(game_manager.calculate_detection_chance(2, true), 0.50, 0.001, "strike 2 + overdue")

func test_fired_at_max_strikes():
	game_manager.balance["detection_base"] = 1.0
	watch_signals(game_manager)
	game_manager.strikes = int(game_manager.balance.max_strikes) - 1
	game_manager._check_game_state("hustle")
	assert_signal_emitted_with_parameters(game_manager, "game_over", ["fired_hustle"])

func test_no_game_over_if_detection_misses():
	game_manager.balance["detection_base"] = 0.0
	game_manager.balance["detection_strike2_bonus"] = 0.0
	game_manager.strikes = int(game_manager.balance.max_strikes) - 1
	watch_signals(game_manager)
	game_manager._check_game_state("hustle")
	assert_signal_not_emitted(game_manager, "game_over")

# === BUG SPIRAL TESTS ===

func test_bug_spiral_emits_game_over():
	game_manager.balance["bug_spiral_threshold"] = 10
	game_manager.balance["win_goal"] = 5000
	game_manager.bugs = 10
	watch_signals(game_manager)
	game_manager._check_game_state()
	assert_signal_emitted_with_parameters(game_manager, "game_over", ["bug_spiral"])

func test_no_bug_spiral_below_threshold():
	game_manager.balance["bug_spiral_threshold"] = 100
	game_manager.balance["win_goal"] = 5000
	game_manager.bugs = 99
	watch_signals(game_manager)
	game_manager._check_game_state()
	assert_signal_not_emitted(game_manager, "game_over")

# === DOUBLE-STRIKE BUG TESTS ===

func test_detection_fires_at_max_does_not_also_trigger_overdue():
	# Detection brings strikes to max and returns early — overdue must not also fire
	game_manager.balance["detection_base"] = 1.0
	game_manager.strikes = int(game_manager.balance.max_strikes) - 1
	game_manager.overdue_days = int(game_manager.balance.max_overdue_days)
	watch_signals(game_manager)
	game_manager._check_game_state("hustle")
	assert_signal_emitted_with_parameters(game_manager, "game_over", ["fired_hustle"])
	assert_eq(game_manager.strikes, int(game_manager.balance.max_strikes), "strikes must not exceed max_strikes")

func test_overdue_fires_at_max_emits_fired_overdue():
	game_manager.balance["detection_base"] = 0.0
	game_manager.strikes = int(game_manager.balance.max_strikes) - 1
	game_manager.overdue_days = int(game_manager.balance.max_overdue_days)
	watch_signals(game_manager)
	game_manager._check_game_state()
	assert_signal_emitted_with_parameters(game_manager, "game_over", ["fired_overdue"])

# === COUNTER TESTS ===

func test_tasks_shipped_increments_on_ship():
	game_manager.do_ship()
	assert_eq(game_manager.tasks_shipped, 1, "tasks_shipped should increment on ship")

func test_tasks_shipped_accumulates():
	game_manager.do_ship()
	game_manager.do_ship()
	assert_eq(game_manager.tasks_shipped, 2, "tasks_shipped should accumulate")

func test_tasks_shipped_resets():
	game_manager.do_ship()
	game_manager.reset()
	assert_eq(game_manager.tasks_shipped, 0, "tasks_shipped should reset")
