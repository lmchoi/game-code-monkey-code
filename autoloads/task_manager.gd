extends Node

signal task_changed(task_data: Dictionary)
signal task_progress_changed(progress: float)

const TASK_MAX_PROGRESS := 100.0

var current_task: Dictionary = {}
var current_progress: float = 0.0

var _tasks: Array = []
var _current_index: int = 0

func _ready() -> void:
	var file = FileAccess.open("res://data/tutorial_tasks.json", FileAccess.READ)
	assert(file != null, "Could not open tutorial_tasks.json")
	_tasks = JSON.parse_string(file.get_as_text())
	assert(_tasks != null, "tutorial_tasks.json is not valid JSON")
	file.close()
	_assign_task(0, GameManager.day)

func advance_progress(delta: float) -> void:
	current_progress = minf(current_progress + delta, TASK_MAX_PROGRESS)
	task_progress_changed.emit(current_progress)

func ship_current(current_day: int) -> void:
	if _current_index < _tasks.size() - 1:
		_assign_task(_current_index + 1, current_day)
	else:
		current_progress = 0.0
		task_progress_changed.emit(current_progress)
		task_changed.emit(current_task)

func reset() -> void:
	_current_index = 0
	current_progress = 0.0
	_assign_task(0, 1)

func _assign_task(index: int, current_day: int) -> void:
	_current_index = index
	current_task = _tasks[index].duplicate()
	current_task["deadline_day"] = current_day + current_task["deadline_days"]
	current_progress = 0.0
	task_changed.emit(current_task)
