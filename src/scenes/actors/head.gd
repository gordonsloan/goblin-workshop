extends Node3D
class_name Head

@export_category("Pan Look")
@export var pan_max_offset: Vector2 = Vector2(0.15, 0.30)
@export var pan_pixels_at_max: float = 400.0
@export var pan_speed: float = 2.5
@export var tilt_max_deg: Vector2 = Vector2(-10.0, 20.0)
@export var pan_curve_gamma: float = 1.8
@export_range(0.0, 1.0, 0.01, "or_greater") var pan_edge_feather: float = 0.5

var can_look: bool = true

@onready var canvas_layer: CanvasLayer = get_node_or_null("CanvasLayer") as CanvasLayer
@onready var camera_3d: Camera3D = $Camera3D
@onready var look_ray: LookRayCast = $Camera3D/LookRayCast

var _base_cam_local_pos: Vector3
var _current_pan: Vector3 = Vector3.ZERO
var _pan_rot: Vector3 = Vector3.ZERO

# PROTOTYPE_DISABLED:
# Drill sway, engine stop shake, hard-layer reactions, and drill-manager signal
# wiring were imported from another project and are intentionally inactive here.


func _ready() -> void:
	_base_cam_local_pos = camera_3d.transform.origin
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func _process(delta: float) -> void:
	if not can_look:
		return

	_apply_cursor_pan(delta)
	_apply_camera_transform()


func _apply_cursor_pan(delta: float) -> void:
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return

	var viewport_size: Vector2 = Vector2(viewport.get_visible_rect().size)
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var mouse: Vector2 = viewport.get_mouse_position()
	var center: Vector2 = viewport_size * 0.5
	var delta_px: Vector2 = mouse - center
	var denom: float = max(1.0, pan_pixels_at_max)
	var normalized: Vector2 = Vector2(
		clamp(delta_px.x / denom, -1.0, 1.0),
		clamp(delta_px.y / denom, -1.0, 1.0)
	)
	var shaped: Vector2 = Vector2(
		_apply_center_hot_curve(normalized.x),
		_apply_center_hot_curve(normalized.y)
	)

	var target_local: Vector3 = Vector3(
		shaped.x * pan_max_offset.x,
		-shaped.y * pan_max_offset.y,
		0.0
	)
	_current_pan = _current_pan.move_toward(target_local, pan_speed * delta)

	_pan_rot = Vector3(
		-deg_to_rad(tilt_max_deg.y) * shaped.y,
		deg_to_rad(tilt_max_deg.x) * shaped.x,
		0.0
	)


func _apply_center_hot_curve(value: float) -> float:
	var amount: float = abs(value)
	var gamma: float = max(1.0, pan_curve_gamma)
	var eased: float = 1.0 - pow(1.0 - amount, gamma)
	var blend: float = clamp(pan_edge_feather, 0.0, 1.0)
	return signf(value) * lerp(amount, eased, blend)


func _apply_camera_transform() -> void:
	var camera_transform: Transform3D = camera_3d.transform
	camera_transform.origin = _base_cam_local_pos + _current_pan
	camera_3d.transform = camera_transform
	rotation = _pan_rot


func set_look_enabled(enabled: bool) -> void:
	can_look = enabled
	if canvas_layer:
		canvas_layer.visible = enabled
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	if look_ray:
		look_ray.set_interaction_enabled(enabled)


func set_look_and_interaction_enabled(enabled: bool) -> void:
	set_look_enabled(enabled)


func reset_look() -> void:
	_current_pan = Vector3.ZERO
	_pan_rot = Vector3.ZERO

	var camera_transform: Transform3D = camera_3d.transform
	camera_transform.origin = _base_cam_local_pos
	camera_3d.transform = camera_transform
	rotation = Vector3.ZERO
