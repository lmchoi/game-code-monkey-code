extends GutTest

var game_manager: Node

func before_each():
	game_manager = GameManager.duplicate()
	add_child_autofree(game_manager)
	game_manager.balance = {
		"bug_penalty_per_bug": 0.01
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
