extends GutTest

var game_manager: Node

func before_each():
	game_manager = GameManager.duplicate()
	add_child_autofree(game_manager)
	game_manager.balance = {
		"bug_penalty_per_bug": 0.01,
		"bugs_per_incomplete_percent": 0.1,
		"detection_base": 0,
		"pip_detection_base": 0.15,
		"detection_overdue_bonus": 0.20,
		"detection_strike1_bonus": 0.10,
		"detection_strike2_bonus": 0.20,
		"max_strikes": 3,
		"max_overdue_days": 3,
		"win_goal": 5000,
		"payday_interval": 5,
		"salary_per_payday": 500,
		"ship_vibe_green": 80,
		"review_day": 30,
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

func test_detection_chance_zero_when_not_on_pip():
	assert_almost_eq(game_manager.calculate_detection_chance(0, false), 0.0, 0.001, "no detection when not on PIP")

func test_detection_chance_pip_base_only():
	game_manager.on_pip = true
	assert_almost_eq(game_manager.calculate_detection_chance(0, false), 0.15, 0.001, "pip base only")

func test_detection_chance_pip_overdue_adds_bonus():
	game_manager.on_pip = true
	assert_almost_eq(game_manager.calculate_detection_chance(0, true), 0.35, 0.001, "pip + overdue bonus")

func test_detection_chance_pip_strike1_adds_bonus():
	game_manager.on_pip = true
	assert_almost_eq(game_manager.calculate_detection_chance(1, false), 0.25, 0.001, "pip + strike 1 bonus")

func test_detection_chance_pip_strike2_adds_bonus():
	game_manager.on_pip = true
	assert_almost_eq(game_manager.calculate_detection_chance(2, false), 0.35, 0.001, "pip + strike 2 bonus")

func test_detection_chance_pip_strike1_and_overdue():
	game_manager.on_pip = true
	assert_almost_eq(game_manager.calculate_detection_chance(1, true), 0.45, 0.001, "pip + strike 1 + overdue")

func test_detection_chance_pip_strike2_and_overdue():
	game_manager.on_pip = true
	assert_almost_eq(game_manager.calculate_detection_chance(2, true), 0.55, 0.001, "pip + strike 2 + overdue")

func test_fired_at_max_strikes():
	game_manager.on_pip = true
	game_manager.balance["pip_detection_base"] = 1.0
	watch_signals(game_manager)
	game_manager.strikes = int(game_manager.balance.max_strikes) - 1
	game_manager._check_game_state("hustle")
	assert_signal_emitted_with_parameters(game_manager, "game_over", ["fired_hustle"])

func test_no_game_over_if_not_on_pip():
	game_manager.strikes = int(game_manager.balance.max_strikes) - 1
	watch_signals(game_manager)
	game_manager._check_game_state("hustle")
	assert_signal_not_emitted(game_manager, "game_over")

# === DOUBLE-STRIKE BUG TESTS ===

func test_detection_fires_at_max_does_not_also_trigger_overdue():
	# Detection brings strikes to max and returns early — overdue must not also fire
	game_manager.on_pip = true
	game_manager.balance["pip_detection_base"] = 1.0
	game_manager.strikes = int(game_manager.balance.max_strikes) - 1
	game_manager.overdue_days = int(game_manager.balance.max_overdue_days)
	watch_signals(game_manager)
	game_manager._check_game_state("hustle")
	assert_signal_emitted_with_parameters(game_manager, "game_over", ["fired_hustle"])
	assert_eq(game_manager.strikes, int(game_manager.balance.max_strikes), "strikes must not exceed max_strikes")

func test_overdue_fires_at_max_emits_fired_overdue():
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

func test_total_bugs_added_increases_on_sloppy_ship():
	TaskManager.current_progress = 50.0
	game_manager.do_ship()
	assert_gt(game_manager.total_bugs_added, 0, "total_bugs_added should increase on sloppy ship")

func test_total_bugs_added_accumulates():
	TaskManager.current_progress = 50.0
	game_manager.do_ship()
	var first_ship_bugs = game_manager.total_bugs_added
	TaskManager.current_progress = 50.0
	game_manager.do_ship()
	assert_eq(game_manager.total_bugs_added, first_ship_bugs * 2, "total_bugs_added should accumulate")

func test_total_bugs_added_zero_on_clean_ship():
	TaskManager.current_progress = 100.0
	game_manager.do_ship()
	assert_eq(game_manager.total_bugs_added, 0, "total_bugs_added should be zero on clean ship")

func test_total_bugs_added_resets():
	TaskManager.current_progress = 50.0
	game_manager.do_ship()
	game_manager.reset()
	assert_eq(game_manager.total_bugs_added, 0, "total_bugs_added should reset")

func test_sloppy_ships_increments_below_green():
	TaskManager.current_progress = 70.0
	game_manager.do_ship()
	assert_eq(game_manager.sloppy_ships, 1, "sloppy_ships should increment when shipping below green threshold")

func test_sloppy_ships_not_incremented_at_green():
	TaskManager.current_progress = 80.0
	game_manager.do_ship()
	assert_eq(game_manager.sloppy_ships, 0, "sloppy_ships should NOT increment when shipping at green threshold")

func test_sloppy_ships_not_incremented_above_green():
	TaskManager.current_progress = 90.0
	game_manager.do_ship()
	assert_eq(game_manager.sloppy_ships, 0, "sloppy_ships should NOT increment when shipping above green threshold")

func test_sloppy_ships_resets():
	TaskManager.current_progress = 50.0
	game_manager.do_ship()
	game_manager.reset()
	assert_eq(game_manager.sloppy_ships, 0, "sloppy_ships should reset")

func test_tasks_on_time_increments_before_deadline():
	game_manager.day = 1
	TaskManager.current_task["deadline_day"] = 5
	game_manager.do_ship()
	assert_eq(game_manager.tasks_on_time, 1, "tasks_on_time should increment")

func test_tasks_late_increments_after_deadline():
	game_manager.day = 10
	TaskManager.current_task["deadline_day"] = 5
	game_manager.do_ship()
	assert_eq(game_manager.tasks_late, 1, "tasks_late should increment")

func test_tasks_on_time_resets():
	game_manager.day = 1
	TaskManager.current_task["deadline_day"] = 5
	game_manager.do_ship()
	game_manager.reset()
	assert_eq(game_manager.tasks_on_time, 0, "tasks_on_time should reset")

func test_tasks_late_resets():
	game_manager.day = 10
	TaskManager.current_task["deadline_day"] = 5
	game_manager.do_ship()
	game_manager.reset()
	assert_eq(game_manager.tasks_late, 0, "tasks_late should reset")

# === REVIEW TESTS ===

func test_review_ready_emits_at_review_day():
	watch_signals(game_manager)
	game_manager.day = int(game_manager.balance.review_day)
	assert_signal_emitted(game_manager, "review_ready")

func test_review_ready_not_emitted_before_review_day():
	watch_signals(game_manager)
	game_manager.day = int(game_manager.balance.review_day) - 1
	assert_signal_not_emitted(game_manager, "review_ready")

func test_review_ready_not_emitted_if_game_over():
	game_manager.game_over_reason = "bug_spiral"
	watch_signals(game_manager)
	game_manager.day = int(game_manager.balance.review_day)
	assert_signal_not_emitted(game_manager, "review_ready")

func test_review_ready_emits_at_review2_day():
	game_manager.balance["review2_day"] = 60
	watch_signals(game_manager)
	game_manager.day = 60
	assert_signal_emitted(game_manager, "review_ready")

func test_review_ready_not_emitted_between_reviews():
	game_manager.balance["review2_day"] = 60
	watch_signals(game_manager)
	game_manager.day = 45
	assert_signal_not_emitted(game_manager, "review_ready")

# === SNAPSHOT TESTS ===

func test_reset_review_counters_pushes_snapshot():
	game_manager.tasks_shipped = 5
	game_manager.sloppy_ships = 1
	game_manager.tasks_on_time = 4
	game_manager.tasks_late = 1
	game_manager.total_bugs_added = 3
	game_manager.reset_review_counters()
	assert_eq(game_manager.review_snapshots.size(), 1, "should have one snapshot")
	var snap = game_manager.review_snapshots[0]
	assert_eq(snap["tasks_shipped"], 5)
	assert_eq(snap["sloppy_ships"], 1)
	assert_eq(snap["tasks_on_time"], 4)
	assert_eq(snap["tasks_late"], 1)
	assert_eq(snap["total_bugs_added"], 3)

func test_reset_review_counters_zeroes_period_vars():
	game_manager.tasks_shipped = 5
	game_manager.sloppy_ships = 2
	game_manager.reset_review_counters()
	assert_eq(game_manager.tasks_shipped, 0, "tasks_shipped should be zeroed")
	assert_eq(game_manager.sloppy_ships, 0, "sloppy_ships should be zeroed")


func test_reset_review_counters_accumulates_snapshots():
	game_manager.tasks_shipped = 7
	game_manager.reset_review_counters()
	game_manager.tasks_shipped = 5
	game_manager.reset_review_counters()
	assert_eq(game_manager.review_snapshots.size(), 2, "should have two snapshots")

func test_review_snapshots_cleared_on_game_reset():
	game_manager.reset_review_counters()
	game_manager.reset()
	assert_eq(game_manager.review_snapshots.size(), 0, "review_snapshots should clear on reset")

# === PIP TESTS ===

func test_on_pip_false_by_default():
	assert_false(game_manager.on_pip, "on_pip should be false by default")

func test_on_pip_resets_on_game_reset():
	game_manager.on_pip = true
	game_manager.reset()
	assert_false(game_manager.on_pip, "on_pip should clear on reset")

func test_hustle_no_detection_when_not_on_pip():
	game_manager.balance["pip_detection_base"] = 1.0
	game_manager.strikes = int(game_manager.balance.max_strikes) - 1
	watch_signals(game_manager)
	game_manager._check_game_state("hustle")
	assert_signal_not_emitted(game_manager, "game_over")

func test_hustle_detection_fires_when_on_pip():
	game_manager.on_pip = true
	game_manager.balance["pip_detection_base"] = 1.0
	game_manager.strikes = int(game_manager.balance.max_strikes) - 1
	watch_signals(game_manager)
	game_manager._check_game_state("hustle")
	assert_signal_emitted_with_parameters(game_manager, "game_over", ["fired_hustle"])

func test_any_grade_needs_improvement_true_when_nothing_shipped():
	game_manager.tasks_shipped = 0
	assert_true(game_manager.any_grade_needs_improvement())

func test_any_grade_needs_improvement_false_when_all_pass():
	game_manager.balance["quality_grade_exceeds"] = 0.9
	game_manager.balance["quality_grade_meets"] = 0.0
	game_manager.balance["output_grade_exceeds"] = 99
	game_manager.balance["output_grade_meets"] = 1
	game_manager.balance["timeliness_grade_exceeds"] = 0.9
	game_manager.balance["timeliness_grade_meets"] = 0.0
	game_manager.tasks_shipped = 1
	game_manager.tasks_on_time = 1
	game_manager.tasks_late = 0
	game_manager.sloppy_ships = 0
	assert_false(game_manager.any_grade_needs_improvement())

