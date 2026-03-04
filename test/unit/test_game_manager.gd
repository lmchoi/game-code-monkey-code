extends GutTest

var game_manager: Node

func before_each():
	game_manager = GameManager.duplicate()
	add_child_autofree(game_manager)
	game_manager.balance = {
		"bug_penalty_per_bug": 0.01,
		"bugs_per_incomplete_percent": 0.1,
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
