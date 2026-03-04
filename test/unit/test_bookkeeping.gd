extends GutTest

var gm: Node

func before_each():
	gm = GameManager.duplicate()
	add_child_autofree(gm)
	gm.balance = {
		"payday_interval": 5,
		"salary_per_payday": 500,
		"win_goal": 5000,
		"bug_spiral_threshold": 100,
		"hustle_income": 200,
		"detection_base": 0.0,
		"detection_overdue_bonus": 0.0,
		"detection_strike1_bonus": 0.0,
		"detection_strike2_bonus": 0.0,
		"max_strikes": 3,
	}
	gm.money = 0
	gm.day = 1

# === PAYDAY TESTS ===

func test_payday_fires_on_interval():
	gm.day = 5
	gm._do_bookkeeping()
	assert_eq(gm.money, 500, "Payday should pay salary on day 5")

func test_payday_does_not_fire_off_interval():
	gm.day = 3
	gm._do_bookkeeping()
	assert_eq(gm.money, 0, "No payday on day 3")

func test_payday_fires_on_second_interval():
	gm.day = 10
	gm._do_bookkeeping()
	assert_eq(gm.money, 500, "Payday should fire again on day 10")

# === WIN CHECK TESTS ===

func test_win_check_emits_game_over_at_goal():
	watch_signals(gm)
	gm.money = 5000
	gm._check_game_state()
	assert_signal_emitted_with_parameters(gm, "game_over", ["win"])

func test_win_check_does_not_fire_below_goal():
	watch_signals(gm)
	gm.money = 4999
	gm._check_game_state()
	assert_signal_not_emitted(gm, "game_over")

# === OVERDUE FLAG TESTS ===

func test_not_overdue_before_deadline():
	assert_false(gm._is_task_overdue(4, 5), "Day 4 with deadline 5 is not overdue")

func test_not_overdue_on_deadline_day():
	assert_false(gm._is_task_overdue(5, 5), "Deadline day itself is not overdue")

func test_overdue_after_deadline():
	assert_true(gm._is_task_overdue(6, 5), "Day 6 with deadline 5 is overdue")

# === HUSTLE TESTS ===

func test_hustle_adds_income():
	gm.do_hustle()
	assert_eq(gm.money, 200, "HUSTLE should add hustle_income to money")

func test_hustle_computes_overdue_before_detection():
	# Tutorial task 1 has deadline_day = 4 (day 1 + 3). Day 10 is overdue.
	# detection_base = 0 so only overdue bonus can trigger detection.
	gm.balance["detection_overdue_bonus"] = 1.0
	gm.day = 10
	gm.do_hustle()
	assert_eq(gm.strikes, 1, "Overdue bonus should fire detection when day > deadline")
