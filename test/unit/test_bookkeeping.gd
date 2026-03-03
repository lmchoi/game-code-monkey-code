extends GutTest

var gm: Node

func before_each():
	gm = GameManager.duplicate()
	add_child_autofree(gm)
	gm.balance = {
		"payday_interval": 5,
		"salary_per_payday": 500,
		"win_goal": 5000,
		"hustle_income": 200
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

# === HUSTLE TESTS ===

func test_hustle_adds_income():
	gm.do_hustle()
	assert_eq(gm.money, 200, "HUSTLE should add hustle_income to money")
