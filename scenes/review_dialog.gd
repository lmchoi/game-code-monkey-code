extends AcceptDialog

signal continued

func _ready() -> void:
	set_flag(Window.FLAG_BORDERLESS, true)
	get_ok_button().text = "Continue"
	confirmed.connect(_on_continue)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.custom_minimum_size = Vector2(280, 0)
	add_child(vbox)

	_add_label(vbox, "30-Day Review", 28)
	_add_label(vbox, "Tasks shipped: %d" % GameManager.tasks_shipped, 20)
	_add_label(vbox, "On time: %d" % GameManager.tasks_on_time, 20)
	_add_label(vbox, "Late: %d" % GameManager.tasks_late, 20)
	_add_label(vbox, "Bugs added: %d" % GameManager.total_bugs_added, 20)
	_add_label(vbox, "Sloppy ships: %d" % GameManager.sloppy_ships, 20)
	_add_label(vbox, "Your performance is noted.", 20)

	popup_centered()

func _add_label(parent: Control, text: String, size: int) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)

func _on_continue() -> void:
	TaskManager.unlock_tier2()
	continued.emit()
	queue_free()
