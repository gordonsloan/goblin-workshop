extends CanvasLayer

@export var wipe_duration: float = 0.30
@export var wipe_color: Color = Color(0.0, 0.0, 0.0, 1.0)

@onready var _overlay: ColorRect = %Overlay

var _tween: Tween = null


func _ready() -> void:
	_overlay.color = wipe_color
	_reset_overlay()
	visible = false


func transition_out() -> void:
	visible = true
	_overlay.anchor_left = 0.0
	_overlay.anchor_right = 0.0
	await _tween_anchor("anchor_right", 1.0)


func transition_in() -> void:
	_overlay.anchor_left = 0.0
	_overlay.anchor_right = 1.0
	await _tween_anchor("anchor_left", 1.0)
	_reset_overlay()
	visible = false


func _reset_overlay() -> void:
	_overlay.anchor_left = 0.0
	_overlay.anchor_top = 0.0
	_overlay.anchor_right = 0.0
	_overlay.anchor_bottom = 1.0
	_overlay.offset_left = 0.0
	_overlay.offset_top = 0.0
	_overlay.offset_right = 0.0
	_overlay.offset_bottom = 0.0


func _tween_anchor(property_name: String, value: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(_overlay, property_name, value, wipe_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	await _tween.finished
