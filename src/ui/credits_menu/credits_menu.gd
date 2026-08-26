extends Control

const MenuAudio := preload("res://src/ui/menu_audio.gd")
const ProjectInfo := preload("res://src/common/project_info.gd")

@onready var _project_name_label: Label = %ProjectNameLabel
@onready var _creator_label: Label = %CreatorLabel
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	PauseManager.set_pause_allowed(false)
	MenuAudio.play_menu_music()
	_project_name_label.text = ProjectInfo.get_project_name()
	_creator_label.text = ProjectInfo.get_creator_credit()
	MenuAudio.wire_button(_back_button, MenuAudio.UI_HOVER, null)
	_back_button.pressed.connect(_on_back_pressed)
	_back_button.grab_focus()


func _on_back_pressed() -> void:
	MenuAudio.play_sfx(MenuAudio.UI_BACK)
	SceneNavigator.go_to_main_menu()
