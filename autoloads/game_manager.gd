extends Node

var balance: Dictionary = {}

func _ready() -> void:
	var file = FileAccess.open("res://data/balance.json", FileAccess.READ)
	assert(file != null, "Could not open balance.json")
	balance = JSON.parse_string(file.get_as_text())
	assert(balance != null, "balance.json is not valid JSON")
	file.close()
