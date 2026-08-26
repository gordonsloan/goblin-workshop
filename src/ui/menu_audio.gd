extends RefCounted

const MENU_MUSIC := "res://src/assets/audio/placeholders/menu_loop.wav"
const UI_HOVER := "res://src/assets/audio/placeholders/ui_hover.wav"
const UI_CONFIRM := "res://src/assets/audio/placeholders/ui_confirm.wav"
const UI_BACK := "res://src/assets/audio/placeholders/ui_back.wav"


static func play_menu_music(stream: Variant = MENU_MUSIC, fade_duration: float = 0.5, volume_db: float = -8.0) -> void:
	if _is_headless():
		return

	var audio_stream := _resolve_audio_stream(stream)
	if audio_stream == null:
		return

	if audio_stream is AudioStreamWAV:
		(audio_stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD

	SoundManager.play_music(audio_stream, fade_duration, volume_db)


static func play_sfx(stream: Variant, volume_db: float = -8.0, pitch_randomness: float = 0.0) -> void:
	if _is_headless():
		return

	var audio_stream := _resolve_audio_stream(stream)
	if audio_stream == null:
		return

	SoundManager.play_sfx(audio_stream, volume_db, 1.0, pitch_randomness)


static func wire_hover(control: Control, hover_stream: Variant = UI_HOVER) -> void:
	if _is_headless():
		return

	if control == null or control.has_meta("menu_hover_audio_wired"):
		return

	control.set_meta("menu_hover_audio_wired", true)

	if hover_stream != null:
		control.mouse_entered.connect(func() -> void:
			play_sfx(hover_stream, -12.0, 0.02)
		)
		control.focus_entered.connect(func() -> void:
			play_sfx(hover_stream, -12.0, 0.02)
		)


static func wire_button(button: BaseButton, hover_stream: Variant = UI_HOVER, pressed_stream: Variant = UI_CONFIRM) -> void:
	if _is_headless():
		return

	if button == null:
		return

	wire_hover(button, hover_stream)

	if button.has_meta("menu_pressed_audio_wired"):
		return

	button.set_meta("menu_pressed_audio_wired", true)

	if pressed_stream != null:
		button.pressed.connect(func() -> void:
			play_sfx(pressed_stream, -8.0, 0.015)
		)


static func wire_hovers(controls: Array, hover_stream: Variant = UI_HOVER) -> void:
	for control in controls:
		wire_hover(control as Control, hover_stream)


static func wire_buttons(buttons: Array, hover_stream: Variant = UI_HOVER, pressed_stream: Variant = UI_CONFIRM) -> void:
	for button in buttons:
		wire_button(button as BaseButton, hover_stream, pressed_stream)


static func _is_headless() -> bool:
	return DisplayServer.get_name() == "headless"


static func _resolve_audio_stream(stream: Variant) -> AudioStream:
	if stream is AudioStream:
		return stream as AudioStream

	if stream is String or stream is StringName:
		return load(str(stream)) as AudioStream

	return null
