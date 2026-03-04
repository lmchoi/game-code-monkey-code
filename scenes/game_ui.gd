extends Control

@onready var _task_title: Label = $MainLayout/TaskCard/CardContent/TaskTitleLabel
@onready var _complexity: Label = $MainLayout/TaskCard/CardContent/MetaRow/ComplexityLabel
@onready var _deadline: Label = $MainLayout/TaskCard/CardContent/MetaRow/DeadlineLabel
@onready var _progress_bar: ProgressBar = $MainLayout/TaskCard/CardContent/TaskProgressBar
@onready var _progress_label: Label = $MainLayout/TaskCard/CardContent/ProgressLabel
@onready var _day_label: Label = $MainLayout/TopBar/HBoxContainer/DayLabel
@onready var _bug_label: Label = $MainLayout/TopBar/HBoxContainer/BugLabel
@onready var _strike_label: Label = $MainLayout/TopBar/HBoxContainer/StrikeLabel
@onready var _money_label: Label = $MainLayout/TopBar/HBoxContainer/MoneyLabel
@onready var _ship_button: Button = $MainLayout/TaskCard/CardContent/ShipButton
@onready var _work_button: Button = $MainLayout/ActionButtons/WorkButton
@onready var _hustle_button: Button = $MainLayout/ActionButtons/HustleButton

func _ready() -> void:
	TaskManager.task_changed.connect(_on_task_changed)
	TaskManager.task_progress_changed.connect(_on_task_progress_changed)
	GameManager.day_changed.connect(_on_day_changed)
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.bugs_changed.connect(_on_bugs_changed)
	GameManager.strikes_changed.connect(_on_strikes_changed)
	_ship_button.pressed.connect(GameManager.do_ship)
	_work_button.pressed.connect(GameManager.do_work)
	_hustle_button.pressed.connect(GameManager.do_hustle)
	GameManager.day_changed.emit(GameManager.day)
	GameManager.money_changed.emit(GameManager.money)
	TaskManager.task_changed.emit(TaskManager.current_task)

func _on_task_changed(task_data: Dictionary) -> void:
	_task_title.text = task_data["title"]
	_complexity.text = "🍝".repeat(task_data["complexity"])
	_deadline.text = "· Due: Day %d" % task_data["deadline_day"]
	_progress_bar.value = 0.0
	_progress_label.text = "0%"
	_work_button.disabled = false
	_ship_button.disabled = true

func _on_day_changed(new_day: int) -> void:
	_day_label.text = "Day %d" % new_day

func _on_strikes_changed(new_strikes: int) -> void:
	_strike_label.visible = new_strikes > 0
	_strike_label.text = "⚠️ %d" % new_strikes

func _on_bugs_changed(new_bugs: int) -> void:
	_bug_label.visible = new_bugs > 0
	_bug_label.text = "🐛 %d" % new_bugs

func _on_money_changed(new_money: int) -> void:
	_money_label.text = "💰 $%d / $%d" % [new_money, int(GameManager.balance.win_goal)]

func _on_task_progress_changed(progress: float) -> void:
	_progress_bar.value = progress
	_progress_label.text = "%d%%" % int(progress)
	_work_button.disabled = progress >= TaskManager.TASK_MAX_PROGRESS
	_ship_button.disabled = progress < GameManager.balance.ship_minimum_progress
