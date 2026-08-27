extends CharacterBody3D
class_name Player

@export_category("Rotation")
@export var turn_step_deg: float = 90.0
@export var turn_duration: float = 0.50
@export var turn_transition: int = Tween.TRANS_QUAD
@export var turn_ease: int = Tween.EASE_IN_OUT

var is_movable: bool = false
var can_turn: bool = true
var can_interact: bool = false

@onready var head: Head = $Head
@onready var camera_3d: Camera3D = $Head/Camera3D
@onready var look_ray: LookRayCast = $Head/Camera3D/LookRayCast

var _target_yaw: float = 0.0
var _turn_tween: Tween = null

# PROTOTYPE_DISABLED:
# Imported carry-item, fishing, room-state, and equipment systems are intentionally
# inactive for Telephone Operator's initial static-view prototype.


func _ready() -> void:
	velocity = Vector3.ZERO
	_target_yaw = rotation.y
	add_to_group("player")
	CameraDirector.register_player(self)


func _input(event: InputEvent) -> void:
	if not can_turn:
		return

	if event.is_action_pressed("interact"):
		_interact_with_current_target()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("move_left"):
		_request_turn(+1)
	elif event.is_action_pressed("move_right"):
		_request_turn(-1)


func _physics_process(_delta: float) -> void:
	velocity = Vector3.ZERO


func _request_turn(dir: int) -> void:
	_target_yaw += deg_to_rad(turn_step_deg) * dir
	_target_yaw = _wrap_angle_pi(_target_yaw)
	_start_turn_tween()


func _start_turn_tween() -> void:
	if _turn_tween and _turn_tween.is_running():
		_turn_tween.kill()

	var delta_angle: float = _shortest_angle(rotation.y, _target_yaw)
	var scaled_duration: float = max(0.01, turn_duration * (abs(delta_angle) / deg_to_rad(turn_step_deg)))
	_turn_tween = create_tween()
	_turn_tween.set_trans(turn_transition)
	_turn_tween.set_ease(turn_ease)
	_turn_tween.tween_property(self, "rotation", Vector3(rotation.x, rotation.y + delta_angle, rotation.z), scaled_duration)


func _shortest_angle(from: float, to: float) -> float:
	var diff: float = fmod(to - from + PI, TAU)
	if diff < 0.0:
		diff += TAU
	return diff - PI


func _wrap_angle_pi(angle: float) -> float:
	var wrapped: float = fmod(angle + PI, TAU)
	if wrapped < 0.0:
		wrapped += TAU
	return wrapped - PI


func update_camera() -> void:
	camera_3d.make_current()


func set_control_enabled(enabled: bool) -> void:
	can_turn = enabled
	is_movable = false
	set_process_input(enabled)
	head.set_look_enabled(enabled)


func update_player_movement(enabled: bool) -> void:
	set_control_enabled(enabled)


func _interact_with_current_target() -> void:
	var target := look_ray.get_current_target()
	if target == null:
		return

	target.interact()
