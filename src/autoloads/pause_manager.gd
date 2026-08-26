extends Node

const PAUSE_MENU_SCENE := preload("res://src/ui/pause_menu/pause_menu.tscn")
const SETTINGS_MENU_SCENE := preload("res://src/ui/settings_menu/settings_menu.tscn")
const SETTINGS_BACK_MODE_SIGNAL_ONLY := 1

var _pause_allowed := false
var _pause_menu: CanvasLayer = null
var _settings_menu: Control = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return

	if not _pause_allowed and not get_tree().paused and not _is_settings_menu_open():
		return

	get_viewport().set_input_as_handled()

	if _is_settings_menu_open():
		_close_settings_menu()
		return

	if get_tree().paused:
		resume_game()
	elif _pause_allowed:
		pause_game()


func set_pause_allowed(value: bool) -> void:
	_pause_allowed = value

	if not _pause_allowed and get_tree().paused:
		resume_game()


func pause_game() -> void:
	if not _pause_allowed or get_tree().paused:
		return

	get_tree().paused = true
	_show_pause_menu()


func resume_game() -> void:
	_close_settings_menu(false)
	_close_pause_menu()
	get_tree().paused = false


func return_to_main_menu() -> void:
	_pause_allowed = false
	_close_settings_menu(false)
	_close_pause_menu()
	get_tree().paused = false
	SceneNavigator.go_to_main_menu()


func _show_pause_menu() -> void:
	if _is_pause_menu_open():
		_pause_menu.visible = true
		_pause_menu.call("grab_default_focus")
		return

	_pause_menu = PAUSE_MENU_SCENE.instantiate()
	_pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(_pause_menu)
	_pause_menu.call("grab_default_focus")
	_pause_menu.connect("resume_requested", Callable(self, "resume_game"))
	_pause_menu.connect("settings_requested", Callable(self, "_open_settings_menu"))
	_pause_menu.connect("main_menu_requested", Callable(self, "return_to_main_menu"))


func _close_pause_menu() -> void:
	if not _is_pause_menu_open():
		_pause_menu = null
		return

	_pause_menu.queue_free()
	_pause_menu = null


func _open_settings_menu() -> void:
	if _is_settings_menu_open():
		return

	if _is_pause_menu_open():
		_pause_menu.visible = false

	_settings_menu = SETTINGS_MENU_SCENE.instantiate()
	_settings_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	_settings_menu.set("back_mode", SETTINGS_BACK_MODE_SIGNAL_ONLY)
	_settings_menu.set("play_menu_music_on_ready", false)
	get_tree().root.add_child(_settings_menu)
	_settings_menu.connect("back_requested", Callable(self, "_close_settings_menu"))


func _close_settings_menu(restore_pause_menu: bool = true) -> void:
	if _is_settings_menu_open():
		_settings_menu.queue_free()

	_settings_menu = null

	if restore_pause_menu and get_tree().paused:
		_show_pause_menu()


func _is_pause_menu_open() -> bool:
	return _pause_menu != null and is_instance_valid(_pause_menu)


func _is_settings_menu_open() -> bool:
	return _settings_menu != null and is_instance_valid(_settings_menu)
