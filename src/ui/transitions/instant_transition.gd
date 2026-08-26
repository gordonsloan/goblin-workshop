extends CanvasLayer


func transition_out() -> void:
	await get_tree().process_frame


func transition_in() -> void:
	await get_tree().process_frame
