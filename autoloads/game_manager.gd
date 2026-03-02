extends Node

signal day_changed(new_day: int)
signal money_changed(new_money: int)

var balance: Dictionary = {}

var bugs: int = 0

var money: int = 0:
	set(value):
		money = value
		money_changed.emit(money)

var day: int = 1:
	set(value):
		day = value
		day_changed.emit(day)

func calculate_progress_delta(complexity: int, bugs_count: int) -> float:
	return TaskManager.TASK_MAX_PROGRESS / (complexity * (1.0 + bugs_count * balance.bug_penalty_per_bug))

func do_work() -> void:
	_constraint_phase()
	var delta := calculate_progress_delta(TaskManager.current_task["complexity"], bugs)
	TaskManager.advance_progress(delta)
	_consequence_phase()
	day += 1

func _constraint_phase() -> void:
	pass

func _consequence_phase() -> void:
	pass

func _ready() -> void:
	var file = FileAccess.open("res://data/balance.json", FileAccess.READ)
	assert(file != null, "Could not open balance.json")
	balance = JSON.parse_string(file.get_as_text())
	assert(balance != null, "balance.json is not valid JSON")
	file.close()
