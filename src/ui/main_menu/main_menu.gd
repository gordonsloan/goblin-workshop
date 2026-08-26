extends Control

const MenuAudio := preload("res://src/ui/menu_audio.gd")
const ProjectInfo := preload("res://src/common/project_info.gd")

@onready var _start_button: Button = %StartButton
@onready var _settings_button: Button = %SettingsButton
@onready var _credits_button: Button = %CreditsButton
@onready var _quit_button: Button = %QuitButton
@onready var _version_label: Label = %VersionLabel


func _ready() -> void:
	PauseManager.set_pause_allowed(false)
	MenuAudio.play_menu_music()
	MenuAudio.wire_buttons([_start_button, _settings_button, _credits_button])
	_version_label.text = ProjectInfo.get_version_label()
	_start_button.pressed.connect(_on_start_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_credits_button.pressed.connect(_on_credits_pressed)
	_configure_quit_button()
	_start_button.grab_focus()


func _on_start_pressed() -> void:
	SoundManager.stop_music(0.25)
	SceneNavigator.start_game()


func _on_settings_pressed() -> void:
	SceneNavigator.go_to_settings()


func _on_credits_pressed() -> void:
	SceneNavigator.go_to_credits()


func _on_quit_pressed() -> void:
	if not SceneNavigator.can_quit_game():
		return

	MenuAudio.play_sfx(MenuAudio.UI_CONFIRM)
	await get_tree().create_timer(0.08).timeout
	SceneNavigator.quit_game()


func _configure_quit_button() -> void:
	var can_quit := SceneNavigator.can_quit_game()
	_quit_button.visible = can_quit
	_quit_button.disabled = not can_quit

	if can_quit:
		MenuAudio.wire_button(_quit_button, MenuAudio.UI_HOVER, null)
		_quit_button.pressed.connect(_on_quit_pressed)
