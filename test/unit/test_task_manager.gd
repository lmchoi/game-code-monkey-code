extends GutTest

var task_manager: Node

func before_each():
	task_manager = TaskManager.duplicate()
	add_child_autofree(task_manager)
	task_manager._ready() # Force load tasks
	task_manager.current_progress = 0.0

# === ADVANCE PROGRESS TESTS ===

func test_advance_progress_adds_delta():
	task_manager.advance_progress(30.0)
	assert_almost_eq(task_manager.current_progress, 30.0, 0.001, "Progress should increase by delta")

func test_advance_progress_clamps_at_max():
	task_manager.current_progress = 70.0
	task_manager.advance_progress(50.0)
	assert_almost_eq(task_manager.current_progress, TaskManager.TASK_MAX_PROGRESS, 0.001, "Progress should not exceed max")

# === SHIP CURRENT TESTS ===

func test_ship_current_advances_to_next_task():
	task_manager._current_index = 0
	task_manager.current_progress = 80.0
	task_manager.ship_current(1)
	assert_eq(task_manager._current_index, 1, "Should advance to next task")
	assert_almost_eq(task_manager.current_progress, 0.0, 0.001, "Progress should reset")

func test_ship_current_transitions_to_pool():
	# Assume 3 tutorial tasks (indices 0, 1, 2)
	# Shipping index 2 should move to index 3 (first task of pool)
	task_manager._current_index = 2
	task_manager.current_progress = 90.0
	task_manager.ship_current(1)
	assert_eq(task_manager._current_index, 3, "Should advance from tutorial to pool")
	assert_eq(task_manager.current_task["title"], "Add a loading spinner to the dashboard", "Should load first pool task")

func test_ship_current_holds_on_last_task():
	# Should hold on the last task of the combined pool
	var last_idx = task_manager._tasks.size() - 1
	task_manager._current_index = last_idx
	task_manager.current_progress = 75.0
	task_manager.ship_current(1)
	assert_eq(task_manager._current_index, last_idx, "Should stay on last task")
	assert_almost_eq(task_manager.current_progress, 0.0, 0.001, "Progress should reset")
