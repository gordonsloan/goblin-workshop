extends Node

enum Mode { FREE_LOOK, CAMERA_MARKER }

@export var transition_time := 0.6
@export var transition_trans := Tween.TRANS_SINE
@export var transition_ease := Tween.EASE_IN_OUT

var mode: int = Mode.FREE_LOOK
var player: Player = null
var head: Head = null
var cam: Camera3D = null

var _tween: Tween = null
var _free_cam_global: Transform3D
var _free_cam_top_level: bool = false

# PROTOTYPE_DISABLED:
# Imported attache case, fishing, radio, held-item reset, and FishingManager
# behavior has been removed until Telephone Operator has matching systems.


func register_player(new_player: Player) -> void:
	player = new_player
	head = player.head
	cam = player.camera_3d
	_capture_free_state()


func transition_to_marker(marker: Node3D) -> void:
	if marker == null:
		push_warning("CameraDirector: transition_to_marker called with null marker.")
		return

	transition_to_transform(marker.global_transform)


func transition_to_transform(target_transform: Transform3D) -> void:
	if not _ensure_player():
		return

	mode = Mode.CAMERA_MARKER
	_capture_free_state()
	player.can_turn = false
	head.set_look_enabled(false)
	cam.top_level = true
	_kill_tween()

	_tween = create_tween()
	_tween.set_trans(transition_trans)
	_tween.set_ease(transition_ease)
	_tween.tween_property(cam, "global_transform", target_transform, transition_time)


func exit_to_free_look() -> void:
	if not _ensure_player():
		return
	if mode == Mode.FREE_LOOK:
		return

	mode = Mode.FREE_LOOK
	_kill_tween()

	_tween = create_tween()
	_tween.set_trans(transition_trans)
	_tween.set_ease(transition_ease)
	_tween.tween_property(cam, "global_transform", _free_cam_global, transition_time)
	_tween.tween_callback(func() -> void:
		cam.top_level = _free_cam_top_level
		head.reset_look()
		player.can_turn = true
		head.set_look_enabled(true)
	)


func _ensure_player() -> bool:
	if player == null:
		var found_player := get_tree().get_first_node_in_group("player") as Player
		if found_player:
			register_player(found_player)

	if player == null or head == null or cam == null:
		push_warning("CameraDirector: player, head, or camera is not registered.")
		return false

	return true


func _capture_free_state() -> void:
	if cam == null:
		return

	_free_cam_global = cam.global_transform
	_free_cam_top_level = cam.top_level


func _kill_tween() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = null
