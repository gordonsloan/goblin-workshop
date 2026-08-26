extends CanvasLayer

@export var fade_duration: float = 0.25
@export var fade_color: Color = Color(0.0, 0.0, 0.0, 1.0)

@onready var _overlay: ColorRect = %Overlay

var _tween: Tween = null


func _ready() -> void:
	_overlay.color = Color(fade_color.r, fade_color.g, fade_color.b, 0.0)
	visible = false


func transition_out() -> void:
	visible = true
	await _fade_to(1.0)


func transition_in() -> void:
	await _fade_to(0.0)
	visible = false


func _fade_to(alpha: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(_overlay, "color:a", alpha, fade_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await _tween.finished
