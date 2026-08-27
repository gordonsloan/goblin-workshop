extends Node3D
class_name ConveyorController

@export var box_scene: PackedScene
@export_node_path("Marker3D") var start_marker_path: NodePath = ^"Markers/Start"
@export_node_path("Marker3D") var centre_marker_path: NodePath = ^"Markers/Centre"
@export_node_path("Marker3D") var end_marker_path: NodePath = ^"Markers/End"
@export var spawn_delay: float = 5.0
@export var travel_duration: float = 2.0
@export var weight_reveal_delay: float = 1.0
@export var min_weight_kg: float = 4.0
@export var max_weight_kg: float = 10.0

@onready var _start_marker: Marker3D = get_node(start_marker_path) as Marker3D
@onready var _centre_marker: Marker3D = get_node(centre_marker_path) as Marker3D
@onready var _end_marker: Marker3D = get_node(end_marker_path) as Marker3D

var _running := false
var _current_box: Node3D = null
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if DisplayServer.get_name() == "headless":
		return

	call_deferred("start_loop")


func _exit_tree() -> void:
	_running = false


func start_loop() -> void:
	if _running:
		return

	if box_scene == null:
		push_warning("ConveyorController has no box scene configured.")
		return

	_running = true
	GameManager.reset_loop_state()
	_run_loop()


func _run_loop() -> void:
	while _running and is_inside_tree():
		await get_tree().create_timer(spawn_delay, false).timeout
		if not _running or not is_inside_tree():
			return

		await _process_next_box()


func _process_next_box() -> void:
	_current_box = box_scene.instantiate() as Node3D
	if _current_box == null or not _current_box.has_method("move_to_global"):
		push_warning("ConveyorController box scene must instantiate a movable Node3D.")
		return

	add_child(_current_box)
	_current_box.global_transform = _start_marker.global_transform

	await _current_box.call("move_to_global", _centre_marker.global_position, travel_duration)
	if not _is_current_box_valid():
		return

	GameManager.set_box_waiting(_current_box)

	await get_tree().create_timer(weight_reveal_delay, false).timeout
	if not _is_current_box_valid():
		return

	GameManager.display_weight(_get_random_weight())
	await GameManager.box_approved
	if not _is_current_box_valid():
		return

	await _current_box.call("move_to_global", _end_marker.global_position, travel_duration)
	if not _is_current_box_valid():
		return

	var cleared_box: Node3D = _current_box
	_current_box = null
	GameManager.clear_current_box(cleared_box)
	cleared_box.queue_free()


func _is_current_box_valid() -> bool:
	return _current_box != null and is_instance_valid(_current_box) and _running


func _get_random_weight() -> float:
	return roundf(_rng.randf_range(min_weight_kg, max_weight_kg) * 10.0) / 10.0
