extends Node

var run_id: int
var log_path: String = "res://logs/game.log"
var enabled: bool = true

func _ready() -> void:
	new_run()

func new_run() -> void:
	run_id = int(Time.get_unix_time_from_system())

func log(fields: Dictionary) -> void:
	if not enabled:
		return
	var entry: Dictionary = fields.duplicate()
	entry["run_id"] = run_id
	entry["ts"] = int(Time.get_unix_time_from_system())

	var json_line: String = JSON.stringify(entry)
	var file: FileAccess = FileAccess.open(log_path, FileAccess.READ_WRITE)
	if not file:
		file = FileAccess.open(log_path, FileAccess.WRITE)
	else:
		file.seek_end()

	if file:
		file.store_line(json_line)
		file.close()
	else:
		push_error("Logger: Could not open log file at " + log_path)

