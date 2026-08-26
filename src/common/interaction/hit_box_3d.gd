extends Area3D
class_name HitBox3D

signal interacted(target: Node)

@export var interactable_path: NodePath
## (Optional) If set, forward interactions to this node; otherwise uses this node's parent.

var targeted: bool = false : set = set_targeted

@onready var _interactable: Node = null

func _ready() -> void:
	# Resolve the interactable target once.
	if String(interactable_path) != "":
		_interactable = get_node_or_null(interactable_path)
	else:
		_interactable = get_parent()

## Set whether this hit box is currently targeted by the player.
func set_targeted(val: bool) -> void:
	if targeted == val:
		return
	targeted = val

## Forward an interaction to the interactable node.
func interact() -> void:
	var target := _interactable
	if target == null or not is_instance_valid(target):
		push_warning("HitBox3D has no valid interact target.")
		return

	interacted.emit(target)

	if not target.has_method("interact"):
		push_warning("HitBox3D interact target has no interact() method.")
		return

	target.call("interact")
