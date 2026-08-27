extends Node3D
class_name Lever

@export_node_path("Node3D") var animated_node_path: NodePath = ^"Marker3D"
@export var pull_angle_deg: float = 45.0
@export var pull_duration: float = 0.15
@export var return_duration: float = 0.75
@export var invalid_jiggle_angle_deg: float = 6.0
@export var invalid_jiggle_duration: float = 0.08

@onready var _animated_node: Node3D = get_node(animated_node_path) as Node3D

var _rest_rotation: Vector3 = Vector3.ZERO
var _animation_tween: Tween = null


func _ready() -> void:
	_rest_rotation = _animated_node.rotation_degrees


func interact() -> void:
	if _animation_tween != null and _animation_tween.is_running():
		return

	if not GameManager.approve_current_box():
		print("No weighed box is ready for approval.")
		_play_invalid_jiggle()
		return

	_play_pull_animation()


func _play_pull_animation() -> void:
	var pulled_rotation := _rest_rotation + Vector3(pull_angle_deg, 0.0, 0.0)
	_animation_tween = create_tween()
	_animation_tween.set_trans(Tween.TRANS_SINE)
	_animation_tween.set_ease(Tween.EASE_OUT)
	_animation_tween.tween_property(_animated_node, "rotation_degrees", pulled_rotation, pull_duration)
	_animation_tween.tween_property(_animated_node, "rotation_degrees", _rest_rotation, return_duration)
	await _animation_tween.finished
	_animation_tween = null


func _play_invalid_jiggle() -> void:
	var left_rotation := _rest_rotation + Vector3(0.0, invalid_jiggle_angle_deg, 0.0)
	var right_rotation := _rest_rotation + Vector3(0.0, -invalid_jiggle_angle_deg, 0.0)
	_animation_tween = create_tween()
	_animation_tween.set_trans(Tween.TRANS_SINE)
	_animation_tween.set_ease(Tween.EASE_IN_OUT)
	_animation_tween.tween_property(_animated_node, "rotation_degrees", left_rotation, invalid_jiggle_duration)
	_animation_tween.tween_property(_animated_node, "rotation_degrees", right_rotation, invalid_jiggle_duration * 2.0)
	_animation_tween.tween_property(_animated_node, "rotation_degrees", _rest_rotation, invalid_jiggle_duration)
	await _animation_tween.finished
	_animation_tween = null
