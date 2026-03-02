extends Node

signal task_changed(task_data: Dictionary)
signal task_progress_changed(progress: float)

var _tasks: Array = []
var _current_index: int = 0
var current_task: Dictionary = {}
var current_progress: float = 0.0

func _ready() -> void:
	var file = FileAccess.open("res://data/tutorial_tasks.json", FileAccess.READ)
	assert(file != null, "Could not open tutorial_tasks.json")
	_tasks = JSON.parse_string(file.get_as_text())
	assert(_tasks != null, "tutorial_tasks.json is not valid JSON")
	file.close()
	_assign_task(0, 1)

func advance_progress(delta: float) -> void:
	current_progress = minf(current_progress + delta, 100.0)
	task_progress_changed.emit(current_progress)

func _assign_task(index: int, current_day: int) -> void:
	_current_index = index
	current_task = _tasks[index].duplicate()
	current_task["deadline_day"] = current_day + current_task["deadline_days"]
	current_progress = 0.0
	task_changed.emit(current_task)
