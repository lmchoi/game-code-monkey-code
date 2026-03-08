extends GutTest

const ReviewDialogScript = preload("res://scenes/review_dialog.gd")


func test_message_satisfactory() -> void:
	var msg: String = ReviewDialogScript.review_message(false, false)
	assert_eq(msg, "Your performance is satisfactory.")


func test_message_placed_on_pip() -> void:
	var msg: String = ReviewDialogScript.review_message(false, true)
	assert_true(msg.begins_with("You are on a PIP."))


func test_message_cleared_pip() -> void:
	var msg: String = ReviewDialogScript.review_message(true, false)
	assert_true(msg.begins_with("You have cleared your PIP."))


func test_message_still_on_pip() -> void:
	var msg: String = ReviewDialogScript.review_message(true, true)
	assert_true(msg.begins_with("You are still underperforming on PIP."))
