extends CanvasLayer
class_name GameUI

@export_category("Reticle")
## The reticle node (optional override if you change the scene structure).
@export var reticle_path: NodePath = "Reticle"
## Idle reticle color.
@export var reticle_idle_color: Color = Color(1.0, 1.0, 1.0, 0.5)
## Targeted reticle color.
@export var reticle_targeted_color: Color = Color(3.0, 0.0, 0.0, 0.75)
## Reticle size in pixels (w, h).
@export var reticle_size: Vector2 = Vector2(2.0, 2.0)

@onready var reticle: ColorRect = get_node_or_null(reticle_path) as ColorRect

func _ready() -> void:
	# Wire reticle updates
	#Global.connect("update_reticle", Callable(self, "_update_reticle"))

	# Initialize reticle visuals
	if reticle:
		reticle.custom_minimum_size = reticle_size
		reticle.size = reticle_size
		reticle.color = reticle_idle_color
	else:
		push_warning("GameUI: Reticle not found at path: %s" % String(reticle_path))

## Update reticle color (and optional pulse) when a target is acquired/cleared.
func _update_reticle(is_targeted: bool) -> void:
	if reticle == null:
		return

	reticle.color = reticle_targeted_color if is_targeted else reticle_idle_color
