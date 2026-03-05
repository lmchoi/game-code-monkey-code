extends GutTest

var game_manager: Node

func before_each():
	game_manager = GameManager.duplicate()
	add_child_autofree(game_manager)
	game_manager.balance = {
		"max_overdue_days": 3,
		"max_strikes": 3,
		"bug_spiral_threshold": 50,
		"win_goal": 5000,
		"payday_interval": 5,
		"salary_per_payday": 500,
	}

# === OVERDUE DAYS TRACKING TESTS ===

func test_overdue_days_increments_when_task_is_overdue():
	TaskManager.current_task["deadline_day"] = 3
	game_manager.day = 5
	game_manager.overdue_days = 0
	game_manager._do_bookkeeping()
	assert_eq(game_manager.overdue_days, 1, "overdue_days should increment when past deadline")
	game_manager.day = 6
	game_manager._do_bookkeeping()
	assert_eq(game_manager.overdue_days, 2, "overdue_days should keep incrementing each overdue day")

func test_overdue_days_resets_when_not_overdue():
	TaskManager.current_task["deadline_day"] = 10
	game_manager.day = 5
	game_manager.overdue_days = 3
	game_manager._do_bookkeeping()
	assert_eq(game_manager.overdue_days, 0, "overdue_days should reset when not overdue")

# === OVERDUE AUTO-ESCALATION TESTS ===

func test_overdue_issues_strike_and_resets_overdue_days():
	game_manager.overdue_days = 3
	game_manager.strikes = 0
	game_manager._check_game_state()
	assert_eq(game_manager.strikes, 1, "should auto-issue a strike when overdue threshold hit")
	assert_eq(game_manager.overdue_days, 0, "should reset overdue_days after issuing strike")

func test_overdue_does_not_fire_game_over_below_max_strikes():
	game_manager.overdue_days = 3
	game_manager.strikes = 1
	watch_signals(game_manager)
	game_manager._check_game_state()
	assert_signal_not_emitted(game_manager, "game_over")

func test_overdue_fires_when_strike_hits_max():
	game_manager.overdue_days = 3
	game_manager.strikes = int(game_manager.balance.max_strikes) - 1
	watch_signals(game_manager)
	game_manager._check_game_state()
	assert_signal_emitted_with_parameters(game_manager, "game_over", ["fired_overdue"])
