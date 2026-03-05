extends Control

@onready var _ending_title: Label = $VBoxContainer/EndingTitleLabel
@onready var _day_label: Label = $VBoxContainer/DayLabel
@onready var _ending_quote: Label = $VBoxContainer/EndingQuoteLabel
@onready var _play_again: Button = $VBoxContainer/PlayAgainButton

func _ready() -> void:
	var reason := GameManager.game_over_reason
	if reason == "fired_hustle":
		_ending_title.text = "CAUGHT RED-HANDED"
		_ending_quote.text = "Security will escort you out."
	elif reason == "fired_overdue":
		_ending_title.text = "TERMINATED FOR CAUSE"
		_ending_quote.text = "Your performance did not meet expectations."
	elif reason == "bug_spiral":
		_ending_title.text = "DEATH SPIRAL"
		_ending_quote.text = "100 bugs. Nothing works. Nothing ever worked."
	else:
		_ending_title.text = "THE PRAGMATIST"
		_ending_quote.text = "You made reasonable decisions under unreasonable conditions. No one will remember."
	_day_label.text = "Day %d" % GameManager.day
	_play_again.pressed.connect(_on_play_again_pressed)

func _on_play_again_pressed() -> void:
	GameManager.reset()
	TaskManager.reset()
	get_tree().change_scene_to_file("res://scenes/game_ui.tscn")
