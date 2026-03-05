extends Node

signal bugs_changed(new_bugs: int)
signal day_changed(new_day: int)
signal game_over(reason: String)
signal money_changed(new_money: int)
signal strikes_changed(new_strikes: int)

var balance: Dictionary = {}
var strikes: int = 0:
	set(value):
		strikes = value
		strikes_changed.emit(strikes)
var task_overdue: bool = false

var bugs: int = 0:
	set(value):
		bugs = value
		bugs_changed.emit(bugs)

var money: int = 0:
	set(value):
		money = value
		money_changed.emit(money)

var day: int = 1:
	set(value):
		day = value
		day_changed.emit(day)

func calculate_bugs_for_ship(progress: float) -> int:
	return roundi((TaskManager.TASK_MAX_PROGRESS - progress) * balance.bugs_per_incomplete_percent)

func calculate_progress_delta(complexity: int, bugs_count: int) -> float:
	return TaskManager.TASK_MAX_PROGRESS / (complexity * (1.0 + bugs_count * balance.bug_penalty_per_bug))

func do_work() -> void:
	_constraint_phase()
	var delta := calculate_progress_delta(TaskManager.current_task["complexity"], bugs)
	var progress_before = TaskManager.current_progress
	TaskManager.advance_progress(delta)

	_do_bookkeeping()

	GameLogger.log({
		"event": "action",
		"day": day,
		"action": "work",
		"bugs": bugs,
		"money": money,
		"progress_before": progress_before,
		"progress_after": TaskManager.current_progress,
		"task": TaskManager.current_task["title"]
	})

	_check_game_state()
	day += 1

func do_ship() -> void:
	_constraint_phase()
	var progress_at_ship = TaskManager.current_progress
	var bugs_added = calculate_bugs_for_ship(progress_at_ship)
	bugs += bugs_added

	TaskManager.ship_current(day)
	_do_bookkeeping()

	GameLogger.log({
		"event": "action",
		"day": day,
		"action": "ship",
		"bugs": bugs,
		"bugs_added": bugs_added,
		"progress_at_ship": progress_at_ship,
		"task": TaskManager.current_task["title"]
	})

	_check_game_state()
	day += 1

func do_hustle() -> void:
	_constraint_phase()
	task_overdue = _is_task_overdue(day, TaskManager.current_task["deadline_day"])
	money += int(balance.hustle_income)

	var strikes_before = strikes
	_hustle_detection()
	var detected = strikes > strikes_before

	_do_bookkeeping()

	GameLogger.log({
		"event": "action",
		"day": day,
		"action": "hustle",
		"bugs": bugs,
		"money": money,
		"detected": detected,
		"strikes": strikes
	})

	_check_game_state()
	day += 1

func calculate_detection_chance(strike_count: int, overdue: bool) -> float:
	var chance: float = balance.detection_base
	if overdue:
		chance += balance.detection_overdue_bonus
	if strike_count == 1:
		chance += balance.detection_strike1_bonus
	elif strike_count == 2:
		chance += balance.detection_strike2_bonus
	return chance

func _hustle_detection() -> void:
	var chance := calculate_detection_chance(strikes, task_overdue)
	if randf() < chance:
		strikes += 1
		if strikes >= int(balance.max_strikes):
			game_over.emit("fired")

func _is_task_overdue(current_day: int, deadline_day: int) -> bool:
	return current_day > deadline_day

func _do_bookkeeping() -> void:
	task_overdue = _is_task_overdue(day, TaskManager.current_task["deadline_day"])
	if day % int(balance.payday_interval) == 0:
		money += int(balance.salary_per_payday)

func _check_game_state() -> void:
	if bugs >= int(balance.bug_spiral_threshold):
		game_over.emit("bug_spiral")
		return
	if money >= int(balance.win_goal):
		game_over.emit("win")

func reset() -> void:
	day = 1
	money = 0
	bugs = 0
	strikes = 0
	task_overdue = false
	GameLogger.new_run()

func _constraint_phase() -> void:
	pass

func _ready() -> void:
	var file = FileAccess.open("res://data/balance.json", FileAccess.READ)
	assert(file != null, "Could not open balance.json")
	balance = JSON.parse_string(file.get_as_text())
	assert(balance != null, "balance.json is not valid JSON")
	file.close()
	TaskManager.task_changed.connect(func(_task): task_overdue = false)
