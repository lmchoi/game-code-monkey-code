extends Node

signal task_changed(task_data: Dictionary)
signal task_progress_changed(progress: float)

const TASK_MAX_PROGRESS := 100.0

var current_task: Dictionary = {}
var current_progress: float = 0.0

var _tasks: Array = []
var _current_index: int = 0

func _ready() -> void:
	_tasks = _load_json("res://data/tutorial_tasks.json")
	assert(_tasks.size() > 0, "Could not load required tutorial_tasks.json")

	var pool_tasks = _load_json("res://data/tasks.json")
	if pool_tasks:
		_tasks.append_array(pool_tasks)

	_assign_task(0, GameManager.day)

func _load_json(path: String) -> Array:
	if not FileAccess.file_exists(path):
		printerr("Could not find file: ", path)
		return []

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)
	if data == null:
		printerr("Failed to parse JSON from: ", path)
		return []

	return data as Array

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
		GameLogger.log({"event": "task_pool_exhausted", "day": current_day, "task": current_task["title"]})

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
