class_name ReviewDialog
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

	_add_label(vbox, "Performance Review", 28)

	vbox.add_child(HSeparator.new())
	_add_label(vbox, "Tasks shipped: %d" % GameManager.tasks_shipped, 20)
	_add_label(vbox, "On time: %d" % GameManager.tasks_on_time, 20)
	_add_label(vbox, "Late: %d" % GameManager.tasks_late, 20)
	_add_label(vbox, "Bugs added: %d" % GameManager.total_bugs_added, 20)
	_add_label(vbox, "Sloppy ships: %d" % GameManager.sloppy_ships, 20)

	vbox.add_child(HSeparator.new())
	_add_label(vbox, "Output: %s" % GameManager.calculate_output_grade(), 24)
	_add_label(vbox, "Timeliness: %s" % GameManager.calculate_timeliness_grade(), 24)
	_add_label(vbox, "Quality: %s" % GameManager.calculate_quality_grade(), 24)

	vbox.add_child(HSeparator.new())
	var any_ni := GameManager.any_grade_needs_improvement()
	_add_label(vbox, review_message(GameManager.on_pip, any_ni), 20, true)
	popup_centered()

static func review_message(on_pip: bool, any_ni: bool) -> String:
	if any_ni and on_pip:
		return "You are still underperforming on PIP. Continuing will result in termination."
	if any_ni:
		return "You are on a PIP. Improve all grades at the next review or you will be fired."
	if on_pip:
		return "You have cleared your PIP. Keep up the good work."
	return "Your performance is satisfactory."


func _add_label(parent: Control, text: String, size: int, wrap: bool = false) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	if wrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)

func _on_continue() -> void:
	var any_needs_improvement = GameManager.any_grade_needs_improvement()
	if GameManager.on_pip and any_needs_improvement:
		GameManager.game_over_reason = "fired_pip"
		GameManager.game_over.emit("fired_pip")
		queue_free()
		return
	GameManager.on_pip = any_needs_improvement
	GameManager.reset_review_counters()
	TaskManager.unlock_next_tier()
	continued.emit()
	queue_free()
