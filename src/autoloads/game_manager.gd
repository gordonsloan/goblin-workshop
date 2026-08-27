extends Node

signal box_waiting(box: Node)
signal box_weight_displayed(box: Node, weight_kg: float)
signal box_approved(box: Node)
signal box_rejected(box: Node)
signal box_resolved(box: Node, decision: StringName)
signal box_cleared(box: Node)
signal productivity_changed(value: float)

var current_box: Node = null
var current_weight_kg: float = 0.0
var is_weight_displayed: bool = false
var is_waiting_for_approval: bool = false
var productivity: float = 90.0

var _productivity_decay_per_second: float = 1.0
var _is_productivity_decaying: bool = false


func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	if not _is_productivity_decaying:
		return

	set_productivity(productivity - (_productivity_decay_per_second * delta))


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


func can_decide_current_box() -> bool:
	return (
		current_box != null
		and is_instance_valid(current_box)
		and is_waiting_for_approval
		and is_weight_displayed
	)


func can_approve_current_box() -> bool:
	return can_decide_current_box()


func approve_current_box() -> bool:
	if not can_approve_current_box():
		return false

	is_waiting_for_approval = false
	box_approved.emit(current_box)
	box_resolved.emit(current_box, &"approved")
	return true


func reject_current_box() -> bool:
	if not can_decide_current_box():
		return false

	is_waiting_for_approval = false
	box_rejected.emit(current_box)
	box_resolved.emit(current_box, &"rejected")
	return true


func clear_current_box(box: Node = null) -> void:
	if box != null and box != current_box:
		return

	var cleared_box := current_box
	reset_loop_state()

	if cleared_box != null:
		box_cleared.emit(cleared_box)


func start_productivity_decay(start_value: float = 90.0, decay_per_second: float = 1.0) -> void:
	productivity = clampf(start_value, 0.0, 100.0)
	_productivity_decay_per_second = maxf(0.0, decay_per_second)
	_is_productivity_decaying = _productivity_decay_per_second > 0.0
	set_process(_is_productivity_decaying)
	productivity_changed.emit(productivity)


func stop_productivity_decay() -> void:
	_is_productivity_decaying = false
	set_process(false)


func set_productivity(value: float) -> void:
	var next_value := clampf(value, 0.0, 100.0)
	if is_equal_approx(productivity, next_value):
		return

	productivity = next_value
	productivity_changed.emit(productivity)

	if productivity <= 0.0:
		stop_productivity_decay()
