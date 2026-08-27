extends Node

signal box_waiting(box: Node)
signal box_weight_displayed(box: Node, weight_kg: float)
signal box_approved(box: Node)
signal box_cleared(box: Node)

var current_box: Node = null
var current_weight_kg: float = 0.0
var is_weight_displayed: bool = false
var is_waiting_for_approval: bool = false


func reset_loop_state() -> void:
	current_box = null
	current_weight_kg = 0.0
	is_weight_displayed = false
	is_waiting_for_approval = false


func set_box_waiting(box: Node) -> void:
	current_box = box
	current_weight_kg = 0.0
	is_weight_displayed = false
	is_waiting_for_approval = true
	box_waiting.emit(box)


func display_weight(weight_kg: float) -> void:
	if current_box == null or not is_instance_valid(current_box):
		return

	current_weight_kg = weight_kg
	is_weight_displayed = true
	box_weight_displayed.emit(current_box, current_weight_kg)


func can_approve_current_box() -> bool:
	return (
		current_box != null
		and is_instance_valid(current_box)
		and is_waiting_for_approval
		and is_weight_displayed
	)


func approve_current_box() -> bool:
	if not can_approve_current_box():
		return false

	is_waiting_for_approval = false
	box_approved.emit(current_box)
	return true


func clear_current_box(box: Node = null) -> void:
	if box != null and box != current_box:
		return

	var cleared_box := current_box
	reset_loop_state()

	if cleared_box != null:
		box_cleared.emit(cleared_box)
