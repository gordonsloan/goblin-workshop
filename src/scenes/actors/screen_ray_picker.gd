# screen_ray_picker.gd (Option A variant)
extends Node3D
class_name ScreenRayPicker

@export var camera: Camera3D
@export var collision_mask: int = 1
@export var max_distance: float = 1.0
@export var collide_with_bodies: bool = true     # <- new (optional)
@export var collide_with_areas: bool = true      # <- new (important)
@export var debug_draw: bool = true
var _hit_marker: MeshInstance3D

@export var container_override: SubViewportContainer

var last_mouse_px: Vector2 = Vector2.ZERO     # in SubViewport pixel space
var last_hit_px:   Vector2 = Vector2.ZERO     # in SubViewport pixel space
var last_hit_world: Vector3 = Vector3.ZERO

func _ready() -> void:
	if camera == null:
		camera = get_parent() as Camera3D

func _ensure_debug_marker() -> void:
	if _hit_marker: return
	_hit_marker = MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.01
	_hit_marker.mesh = sm
	_hit_marker.visible = true
	_hit_marker.top_level = true       # keep it in world space
	add_child(_hit_marker)

func _mouse_pos_in_camera_viewport() -> Vector2:
	var vp := camera.get_viewport()  # SubViewport or the main Viewport

	# Prefer a SubViewportContainer if present (handles scaling/letterboxing in UI)
	var container := container_override
	if container == null and vp.get_parent() is SubViewportContainer:
		container = vp.get_parent() as SubViewportContainer

	if container:
		# Mouse in window/UI space -> local inside the container's rect
		var rect: Rect2 = container.get_global_rect()
		var mouse_global: Vector2 = container.get_global_mouse_position()
		var mouse_in_container: Vector2 = mouse_global - rect.position

		# Scale container-local coords into the SubViewport's pixel space
		var vp_size: Vector2 = Vector2(vp.size)
		if rect.size.x > 0.0 and rect.size.y > 0.0:
			var scale: Vector2 = vp_size / rect.size
			return mouse_in_container * scale
		return vp_size * 0.5  # fallback

	# No container? Fall back to visible-rect (letterbox) correction
	var mouse_pos: Vector2 = vp.get_mouse_position()
	var vis: Rect2 = vp.get_visible_rect()
	if vis.position != Vector2.ZERO:
		mouse_pos -= vis.position
	var vp_size2: Vector2 = Vector2(vp.size)
	if vis.size != vp_size2 and vis.size.x > 0.0 and vis.size.y > 0.0:
		var scale2: Vector2 = vp_size2 / vis.size
		mouse_pos *= scale2
	last_mouse_px = mouse_pos
	return mouse_pos

func get_current_target() -> Object:
	if camera == null:
		return null

	# Build the ray from this corrected screen position
	var mouse_pos: Vector2 = _mouse_pos_in_camera_viewport()

	var from: Vector3 = camera.project_ray_origin(mouse_pos)
	var dir:  Vector3 = camera.project_ray_normal(mouse_pos)
	var to:   Vector3 = from + dir * max_distance

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = collision_mask
	query.collide_with_bodies = collide_with_bodies
	query.collide_with_areas  = collide_with_areas

	var hit: Dictionary = space_state.intersect_ray(query)
	if hit.is_empty():
		if debug_draw and _hit_marker:
			_hit_marker.visible = false
		last_hit_px = Vector2.ZERO
		return null

	if debug_draw:
		_ensure_debug_marker()
		_hit_marker.global_transform.origin = hit["position"]
		_hit_marker.visible = true

	# store debug data
	last_hit_world = hit["position"]
	last_hit_px = camera.unproject_position(last_hit_world)

	return hit["collider"]
