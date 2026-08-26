extends Node3D
class_name LookRayCast

@export var camera: Camera3D
@export var collision_mask: int = 1
@export var enabled_now: bool = true
@export var ray_length: float = 2000.0

var looking_at: HitBox3D = null

var _subvp: SubViewport
var _svc: SubViewportContainer


func _ready() -> void:
	if camera == null:
		camera = get_parent() as Camera3D
	_subvp = camera.get_viewport() as SubViewport
	_svc = _find_container_for_viewport(_subvp)


func _physics_process(_delta: float) -> void:
	if not enabled_now or camera == null:
		return

	var mouse_px: Vector2 = _mouse_in_subviewport_pixels()
	if mouse_px == Vector2.INF:
		return

	var from: Vector3 = camera.project_ray_origin(mouse_px)
	var dir:  Vector3 = camera.project_ray_normal(mouse_px)
	var to:   Vector3 = from + dir * ray_length

	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result := space.intersect_ray(query)
	var new_target: HitBox3D = null
	if result.has("collider"):
		new_target = _get_hitbox(result["collider"])

	_update_target_highlight(new_target)


# --- Mouse mapping (handles Stretch + stretch_shrink on SubViewportContainer) ---
func _mouse_in_subviewport_pixels() -> Vector2:
	# Preferred: map via the container so we always match what is drawn.
	if _subvp and _svc:
		# Mouse in container canvas space
		var global_mouse_in_canvas: Vector2 = _svc.get_global_mouse_position()
		# To container-local
		var xf: Transform2D = _svc.get_global_transform_with_canvas()
		var local_in_container: Vector2 = xf.affine_inverse() * global_mouse_in_canvas

		var cont_size: Vector2 = _svc.get_global_rect().size
		var sv_size: Vector2 = Vector2(_subvp.size)
		if cont_size.x <= 0.0 or cont_size.y <= 0.0 or sv_size.x <= 0.0 or sv_size.y <= 0.0:
			return Vector2.INF

		# stretch_shrink: container draws at (sv_size / shrink) and scales up visually
		var shrink: float = max(1.0, float(_svc.stretch_shrink))
		var pixel_grid: Vector2 = sv_size / shrink

		# If Stretch = On (aspect-preserving), letterboxing can occur. Detect via _svc.stretch.
		if _svc.stretch:
			var scale_fit: float = min(cont_size.x / pixel_grid.x, cont_size.y / pixel_grid.y)
			var content_draw_size: Vector2 = pixel_grid * scale_fit
			var letterbox_offset: Vector2 = (cont_size - content_draw_size) * 0.5
			var local_in_content: Vector2 = local_in_container - letterbox_offset
			var on_pixel_grid: Vector2 = local_in_content / max(0.000001, scale_fit)
			var mouse_in_sv: Vector2 = on_pixel_grid * shrink
			return mouse_in_sv.clamp(Vector2.ZERO, sv_size - Vector2(1, 1))
		else:
			# Full stretch: container rect maps directly to pixel grid
			var scale_vec: Vector2 = Vector2(
				pixel_grid.x / cont_size.x,
				pixel_grid.y / cont_size.y
			)
			var on_pixel_grid_fs: Vector2 = local_in_container * scale_vec
			var mouse_in_sv_fs: Vector2 = on_pixel_grid_fs * shrink
			return mouse_in_sv_fs.clamp(Vector2.ZERO, sv_size - Vector2(1, 1))

	# Fallbacks (rarely used, but safe)
	if _subvp:
		var mp: Vector2 = _subvp.get_mouse_position()
		if mp != Vector2.ZERO or _subvp.has_focus():
			return mp.clamp(Vector2.ZERO, Vector2(_subvp.size) - Vector2(1, 1))

	var vp := get_viewport()
	return (vp.get_mouse_position() if vp else Vector2.INF)


# --- Public API ---
func set_interaction_enabled(enabled_in: bool) -> void:
	enabled_now = enabled_in
	if not enabled_in:
		_update_target_highlight(null)

func get_current_target() -> HitBox3D:
	return looking_at


# --- Helpers ---
func _get_hitbox(n: Node) -> HitBox3D:
	var cursor: Node = n
	while cursor and not (cursor is HitBox3D):
		cursor = cursor.get_parent()
	return cursor as HitBox3D

func _update_target_highlight(target: HitBox3D) -> void:
	if target == looking_at:
		return
	if looking_at:
		looking_at.targeted = false
	looking_at = target
	if looking_at:
		looking_at.targeted = true
		print("Looking At: ", target)

func _find_container_for_viewport(sv: SubViewport) -> SubViewportContainer:
	if sv == null:
		return null
	var node: Node = sv.get_parent()
	while node:
		if node is SubViewportContainer:
			return node as SubViewportContainer
		node = node.get_parent()
	return null
