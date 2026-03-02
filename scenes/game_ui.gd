extends Control

@onready var _task_title: Label = $MainLayout/TaskCard/CardContent/TaskTitleLabel
@onready var _complexity: Label = $MainLayout/TaskCard/CardContent/MetaRow/ComplexityLabel
@onready var _deadline: Label = $MainLayout/TaskCard/CardContent/MetaRow/DeadlineLabel
@onready var _progress_bar: ProgressBar = $MainLayout/TaskCard/CardContent/TaskProgressBar
@onready var _progress_label: Label = $MainLayout/TaskCard/CardContent/ProgressLabel
@onready var _work_button: Button = $MainLayout/ActionButtons/WorkButton

func _ready() -> void:
	TaskManager.task_changed.connect(_on_task_changed)
	TaskManager.task_progress_changed.connect(_on_task_progress_changed)
	_work_button.disabled = false
	_work_button.pressed.connect(GameManager.do_work)
	if not TaskManager.current_task.is_empty():
		_on_task_changed(TaskManager.current_task)

func _on_task_changed(task_data: Dictionary) -> void:
	_task_title.text = task_data["title"]
	_complexity.text = "🍝".repeat(task_data["complexity"])
	_deadline.text = "· Due: Day %d" % task_data["deadline_day"]
	_progress_bar.value = 0.0
	_progress_label.text = "0%"
	_work_button.disabled = false

func _on_task_progress_changed(progress: float) -> void:
	_progress_bar.value = progress
	_progress_label.text = "%d%%" % int(progress)
	_work_button.disabled = progress >= TaskManager.TASK_MAX_PROGRESS
