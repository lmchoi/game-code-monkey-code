extends Node

signal task_changed(task_data: Dictionary)
signal task_progress_changed(progress: float)

const TASK_MAX_PROGRESS := 100.0

var current_task: Dictionary = {}
var current_progress: float = 0.0

var _tasks: Array = []
var _current_index: int = 0
var _base_tasks: Array = []  ## tutorial + tier1; restored on reset
var _tier2_tasks: Array = []  ## parsed once at startup, appended on unlock
var _tier2_unlocked: bool = false

## Loads tutorial tasks and tier1 pool. Tier2 is not added to _tasks
## until unlock_tier2() is called.
func _ready() -> void:
	var tutorial = _load_tasks_json("res://data/tutorial_tasks.json")
	assert(tutorial.size() > 0, "Could not load required tutorial_tasks.json")

	var pool = _parse_tasks_file("res://data/tasks.json")
	_base_tasks = tutorial + pool.get("tier1", [])
	_tier2_tasks = pool.get("tier2", [])
	_tasks = _base_tasks.duplicate(true)
	_assign_task(0, GameManager.day)

## Reads and parses a JSON file. Returns null on missing file or parse error.
func _read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		printerr("Could not find file: ", path)
		return null
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null:
		printerr("Failed to parse JSON from: ", path)
	return data

## Loads a JSON file and returns its contents as a flat Array.
## Handles both raw Array files and {tier1, tier2} Dictionary files.
func _load_tasks_json(path: String) -> Array:
	var data = _read_json(path)
	if data is Array:
		return data
	if data is Dictionary:
		var flattened := []
		if data.has("tier1"):
			flattened.append_array(data["tier1"])
		if data.has("tier2"):
			flattened.append_array(data["tier2"])
		return flattened
	return []

## Parses a tasks JSON file and returns the raw Dictionary.
## Falls back to wrapping a bare Array as {"tier1": array}.
func _parse_tasks_file(path: String) -> Dictionary:
	var data = _read_json(path)
	if data is Dictionary:
		return data
	if data is Array:
		return {"tier1": data}
	return {}

## Adds delta to current progress, clamped at TASK_MAX_PROGRESS.
func advance_progress(delta: float) -> void:
	current_progress = minf(current_progress + delta, TASK_MAX_PROGRESS)
	task_progress_changed.emit(current_progress)

## Ships the current task. Advances to the next task if one exists,
## otherwise holds on the last task and logs task_pool_exhausted.
func ship_current(current_day: int) -> void:
	if _current_index < _tasks.size() - 1:
		_assign_task(_current_index + 1, current_day)
	else:
		current_progress = 0.0
		task_progress_changed.emit(current_progress)
		task_changed.emit(current_task)
		GameLogger.log({"event": "task_pool_exhausted", "day": current_day, "task": current_task["title"]})

## Appends tier2 tasks to the sequence. Idempotent — safe to call multiple times.
## The next ship_current() call will advance naturally into tier2.
func unlock_tier2() -> void:
	if _tier2_unlocked:
		return
	_tier2_unlocked = true
	_tasks.append_array(_tier2_tasks)

## Resets to the start of the tutorial. Strips tier2 from _tasks.
func reset() -> void:
	_tasks = _base_tasks.duplicate(true)
	_tier2_unlocked = false
	_current_index = 0
	current_progress = 0.0
	_assign_task(0, 1)

## Sets the active task by index, computes its deadline_day, and emits task_changed.
func _assign_task(index: int, current_day: int) -> void:
	_current_index = index
	current_task = _tasks[index].duplicate(true)
	current_task["deadline_day"] = current_day + current_task["deadline_days"]
	current_progress = 0.0
	task_changed.emit(current_task)
