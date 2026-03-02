extends GutTest

var task_manager: Node

func before_each():
	task_manager = TaskManager.duplicate()
	add_child_autofree(task_manager)
	task_manager.current_progress = 0.0

# === ADVANCE PROGRESS TESTS ===

func test_advance_progress_adds_delta():
	task_manager.advance_progress(30.0)
	assert_almost_eq(task_manager.current_progress, 30.0, 0.001, "Progress should increase by delta")

func test_advance_progress_clamps_at_max():
	task_manager.current_progress = 70.0
	task_manager.advance_progress(50.0)
	assert_almost_eq(task_manager.current_progress, TaskManager.TASK_MAX_PROGRESS, 0.001, "Progress should not exceed max")
