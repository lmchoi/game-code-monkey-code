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
	# Transition happens after the last tutorial task
	# We know tutorial tasks are the first few in the _tasks array
	var tutorial_count = 3 # This matches tutorial_tasks.json
	task_manager._current_index = tutorial_count - 1
	task_manager.current_progress = 90.0
	task_manager.ship_current(1)

	assert_eq(task_manager._current_index, tutorial_count, "Should advance from tutorial to pool")

func test_ship_current_holds_on_last_task():
	# Should hold on the last task of the combined pool
	var last_idx = task_manager._tasks.size() - 1
	task_manager._current_index = last_idx
	task_manager.current_progress = 75.0
	task_manager.ship_current(1)
	assert_eq(task_manager._current_index, last_idx, "Should stay on last task")
	assert_almost_eq(task_manager.current_progress, 0.0, 0.001, "Progress should reset")

func test_load_tasks_json_tiered_dict():
	# Create a temporary JSON file with tiers
	var path = "user://test_tiered.json"
	var data = {
		"tier1": [{"title": "t1", "deadline_days": 1}],
		"tier2": [{"title": "t2", "deadline_days": 2}]
	}
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

	var loaded = task_manager._load_tasks_json(path)
	assert_eq(loaded.size(), 2, "Should load both tiers")
	assert_eq(loaded[0].title, "t1", "Tier 1 should come first")
	assert_eq(loaded[1].title, "t2", "Tier 2 should come second")

	DirAccess.remove_absolute(path)

# === TIER SEQUENCE TESTS ===

func test_tier1_holds_when_tier1_exhausted():
	var last = task_manager._tasks.size() - 1
	task_manager._current_index = last
	task_manager.current_progress = 80.0
	task_manager.ship_current(1)
	assert_eq(task_manager._current_index, last, "Should hold on last tier1 task")
	assert_almost_eq(task_manager.current_progress, 0.0, 0.001, "Progress should reset")

func test_unlock_tier2_appends_tier2_tasks():
	var size_before = task_manager._tasks.size()
	var index_before = task_manager._current_index
	task_manager.unlock_tier2()
	assert_gt(task_manager._tasks.size(), size_before, "Should have more tasks after unlock")
	assert_eq(task_manager._current_index, index_before, "Should not advance — player must ship first")

func test_tier2_advances_after_unlock():
	var tier1_last = task_manager._tasks.size() - 1
	task_manager._current_index = tier1_last
	task_manager.unlock_tier2()
	task_manager.ship_current(2)
	assert_eq(task_manager._current_index, tier1_last + 1, "Should advance into tier2 after shipping")

func test_reset_resets_tier2_unlock():
	var tier1_size = task_manager._tasks.size()
	task_manager._current_index = tier1_size - 1
	task_manager.unlock_tier2()
	task_manager.reset()
	assert_eq(task_manager._tasks.size(), tier1_size, "After reset, tier2 tasks should be removed")
	task_manager._current_index = task_manager._tasks.size() - 1
	task_manager.ship_current(1)
	assert_eq(task_manager._current_index, task_manager._tasks.size() - 1, "After reset, should hold at tier1 end")

func test_load_tasks_json_fallback_empty():
	# Create a temporary JSON file with invalid shape (e.g., int)
	var path = "user://test_invalid.json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("123")
	file.close()

	var loaded = task_manager._load_tasks_json(path)
	assert_eq(loaded, [], "Should return empty array for invalid JSON shape")

	DirAccess.remove_absolute(path)
