extends Node3D
class_name BoxItem

@export var movement_transition: Tween.TransitionType = Tween.TRANS_SINE
@export var movement_ease: Tween.EaseType = Tween.EASE_IN_OUT

var _movement_tween: Tween = null


func move_to_global(target_position: Vector3, duration: float) -> void:
	if _movement_tween != null and _movement_tween.is_running():
		_movement_tween.kill()

	_movement_tween = create_tween()
	_movement_tween.set_trans(movement_transition)
	_movement_tween.set_ease(movement_ease)
	_movement_tween.tween_property(self, "global_position", target_position, maxf(0.01, duration))
	await _movement_tween.finished
	_movement_tween = null
