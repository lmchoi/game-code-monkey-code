extends Control

@onready var _ending_title: Label = $VBoxContainer/EndingTitleLabel
@onready var _day_label: Label = $VBoxContainer/DayLabel
@onready var _ending_quote: Label = $VBoxContainer/EndingQuoteLabel
@onready var _play_again: Button = $VBoxContainer/PlayAgainButton

func _ready() -> void:
	_ending_title.text = "THE PRAGMATIST"
	_day_label.text = "Day %d" % GameManager.day
	_ending_quote.text = "You made reasonable decisions under unreasonable conditions. No one will remember."
	_play_again.pressed.connect(_on_play_again_pressed)

func _on_play_again_pressed() -> void:
	GameManager.reset()
	TaskManager.reset()
	get_tree().change_scene_to_file("res://scenes/game_ui.tscn")
