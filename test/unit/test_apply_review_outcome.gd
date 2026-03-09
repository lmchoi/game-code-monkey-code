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
		"hustle_income": 200,
		"ship_minimum_progress": 50,
		"ship_vibe_green": 80,
		"review_day": 30,
		"review2_day": 60,
	}


func test_apply_review_outcome_sets_pip_when_any_ni():
	game_manager.balance["output_grade_meets"] = 9999  # force NI
	game_manager.apply_review_outcome()
	assert_true(game_manager.on_pip)


func test_apply_review_outcome_clears_pip_when_all_passing():
	game_manager.on_pip = true
	game_manager.tasks_shipped = 10
	game_manager.tasks_on_time = 10
	game_manager.total_bugs_added = 0
	game_manager.sloppy_ships = 0
	game_manager.balance["quality_grade_exceeds"] = 0.9
	game_manager.balance["quality_grade_meets"] = 0.6
	game_manager.balance["output_grade_exceeds"] = 8
	game_manager.balance["output_grade_meets"] = 5
	game_manager.balance["timeliness_grade_exceeds"] = 0.8
	game_manager.balance["timeliness_grade_meets"] = 0.5
	game_manager.apply_review_outcome()
	assert_false(game_manager.on_pip)


func test_apply_review_outcome_fired_pip_when_ni_while_on_pip():
	game_manager.on_pip = true
	game_manager.balance["output_grade_meets"] = 9999  # force NI
	watch_signals(game_manager)
	game_manager.apply_review_outcome()
	assert_signal_emitted_with_parameters(game_manager, "game_over", ["fired_pip"])


func test_apply_review_outcome_resets_counters():
	game_manager.tasks_shipped = 5
	game_manager.balance["quality_grade_exceeds"] = 9999  # force quality NI
	game_manager.balance["quality_grade_meets"] = 9999
	game_manager.apply_review_outcome()
	assert_eq(game_manager.tasks_shipped, 0)
