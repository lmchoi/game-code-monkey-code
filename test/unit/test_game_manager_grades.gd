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
		"max_overdue_days": 3,
		"win_goal": 5000,
		"payday_interval": 5,
		"salary_per_payday": 500,
		"ship_vibe_green": 80,
		"review_day": 30,
	}

# === GRADE TESTS ===

func test_quality_grade_exceeds():
	game_manager.balance["quality_grade_exceeds"] = 0.9
	game_manager.tasks_shipped = 10
	game_manager.sloppy_ships = 1 # 90% clean
	assert_eq(game_manager.calculate_quality_grade(), "Exceeds Expectations")

func test_quality_grade_meets():
	game_manager.balance["quality_grade_exceeds"] = 0.9
	game_manager.balance["quality_grade_meets"] = 0.6
	game_manager.tasks_shipped = 10
	game_manager.sloppy_ships = 4 # 60% clean
	assert_eq(game_manager.calculate_quality_grade(), "Meets Expectations")

func test_quality_grade_needs_improvement():
	game_manager.balance["quality_grade_exceeds"] = 0.9
	game_manager.balance["quality_grade_meets"] = 0.6
	game_manager.tasks_shipped = 10
	game_manager.sloppy_ships = 5 # 50% clean
	assert_eq(game_manager.calculate_quality_grade(), "Needs Improvement")

func test_quality_grade_all_sloppy():
	game_manager.balance["quality_grade_exceeds"] = 0.9
	game_manager.balance["quality_grade_meets"] = 0.6
	game_manager.tasks_shipped = 5
	game_manager.sloppy_ships = 5
	assert_eq(game_manager.calculate_quality_grade(), "Needs Improvement")

func test_quality_grade_zero_shipped():
	game_manager.tasks_shipped = 0
	game_manager.sloppy_ships = 0
	assert_eq(game_manager.calculate_quality_grade(), "Needs Improvement")

func test_output_grade_exceeds():
	game_manager.balance["output_grade_exceeds"] = 8
	game_manager.tasks_shipped = 8
	assert_eq(game_manager.calculate_output_grade(), "Exceeds Expectations")

func test_output_grade_meets():
	game_manager.balance["output_grade_exceeds"] = 8
	game_manager.balance["output_grade_meets"] = 5
	game_manager.tasks_shipped = 5
	assert_eq(game_manager.calculate_output_grade(), "Meets Expectations")

func test_output_grade_needs_improvement():
	game_manager.balance["output_grade_exceeds"] = 8
	game_manager.balance["output_grade_meets"] = 5
	game_manager.tasks_shipped = 4
	assert_eq(game_manager.calculate_output_grade(), "Needs Improvement")

func test_output_grade_zero_shipped():
	game_manager.balance["output_grade_exceeds"] = 8
	game_manager.balance["output_grade_meets"] = 5
	game_manager.tasks_shipped = 0
	assert_eq(game_manager.calculate_output_grade(), "Needs Improvement")

func test_timeliness_grade_exceeds():
	game_manager.balance["timeliness_grade_exceeds"] = 0.8
	game_manager.tasks_on_time = 8
	game_manager.tasks_late = 2 # 80% on time
	assert_eq(game_manager.calculate_timeliness_grade(), "Exceeds Expectations")

func test_timeliness_grade_meets():
	game_manager.balance["timeliness_grade_exceeds"] = 0.8
	game_manager.balance["timeliness_grade_meets"] = 0.5
	game_manager.tasks_on_time = 5
	game_manager.tasks_late = 5 # 50% on time
	assert_eq(game_manager.calculate_timeliness_grade(), "Meets Expectations")

func test_timeliness_grade_needs_improvement():
	game_manager.balance["timeliness_grade_exceeds"] = 0.8
	game_manager.balance["timeliness_grade_meets"] = 0.5
	game_manager.tasks_on_time = 4
	game_manager.tasks_late = 6 # 40% on time
	assert_eq(game_manager.calculate_timeliness_grade(), "Needs Improvement")

func test_timeliness_grade_zero_shipped():
	game_manager.tasks_on_time = 0
	game_manager.tasks_late = 0
	assert_eq(game_manager.calculate_timeliness_grade(), "Needs Improvement")
