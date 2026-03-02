extends Node

var balance: Dictionary = {}

var bugs: int = 0

func calculate_progress_delta(complexity: int, bugs_count: int) -> float:
	return 100.0 / (complexity * (1.0 + bugs_count * balance.bug_penalty_per_bug))

func _ready() -> void:
	var file = FileAccess.open("res://data/balance.json", FileAccess.READ)
	assert(file != null, "Could not open balance.json")
	balance = JSON.parse_string(file.get_as_text())
	assert(balance != null, "balance.json is not valid JSON")
	file.close()
