extends Node3D
class_name ControlPanelButton

@export_node_path("Node3D") var animated_node_path: NodePath = ^"MeshInstance3D"
@export var press_depth: float = 0.045
@export var press_duration: float = 0.08
@export var return_duration: float = 0.18

@onready var _animated_node: Node3D = get_node(animated_node_path) as Node3D

var _rest_position: Vector3 = Vector3.ZERO
var _animation_tween: Tween = null


func _ready() -> void:
	_rest_position = _animated_node.position


func interact() -> void:
	if _animation_tween != null and _animation_tween.is_running():
		return

	var rejected := GameManager.reject_current_box()
	if not rejected:
		print("No weighed box is ready for rejection.")

	_play_press_animation()


func _play_press_animation() -> void:
	var pressed_position := _rest_position + Vector3(0.0, -press_depth, 0.0)
	_animation_tween = create_tween()
	_animation_tween.set_trans(Tween.TRANS_SINE)
	_animation_tween.set_ease(Tween.EASE_OUT)
	_animation_tween.tween_property(_animated_node, "position", pressed_position, press_duration)
	_animation_tween.tween_property(_animated_node, "position", _rest_position, return_duration)
	await _animation_tween.finished
	_animation_tween = null
