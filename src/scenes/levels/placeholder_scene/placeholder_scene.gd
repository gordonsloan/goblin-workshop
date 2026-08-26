extends Control

const MenuAudio := preload("res://src/ui/menu_audio.gd")

@onready var _back_button: Button = %BackButton


func _ready() -> void:
	PauseManager.set_pause_allowed(true)
	MenuAudio.wire_button(_back_button, MenuAudio.UI_HOVER, null)
	_back_button.pressed.connect(_on_back_pressed)
	_back_button.grab_focus()


func _on_back_pressed() -> void:
	MenuAudio.play_sfx(MenuAudio.UI_BACK)
	PauseManager.set_pause_allowed(false)
	SceneNavigator.go_to_main_menu()
