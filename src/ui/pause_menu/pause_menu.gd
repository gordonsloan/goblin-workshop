extends CanvasLayer

signal resume_requested
signal settings_requested
signal main_menu_requested

const MenuAudio := preload("res://src/ui/menu_audio.gd")

@onready var _resume_button: Button = %ResumeButton
@onready var _settings_button: Button = %SettingsButton
@onready var _main_menu_button: Button = %MainMenuButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	MenuAudio.wire_buttons([_resume_button, _settings_button, _main_menu_button])
	_resume_button.pressed.connect(_on_resume_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_main_menu_button.pressed.connect(_on_main_menu_pressed)
	grab_default_focus()


func grab_default_focus() -> void:
	if _resume_button == null:
		return

	_resume_button.grab_focus()


func _on_resume_pressed() -> void:
	resume_requested.emit()


func _on_settings_pressed() -> void:
	settings_requested.emit()


func _on_main_menu_pressed() -> void:
	main_menu_requested.emit()
