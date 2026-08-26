extends Node

enum WindowMode {
	WINDOWED,
	FULLSCREEN,
}

const DEFAULT_WINDOW_MODE: int = WindowMode.WINDOWED
const DEFAULT_WINDOW_MODE_SETTING: StringName = &"starter_template/display/default_window_mode"
const DEFAULT_WINDOW_SIZE: Vector2i = Vector2i(1280, 720)
const DEFAULT_VSYNC_ENABLED: bool = true
const SETTINGS_FILE_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "display"
const WINDOW_MODE_KEY := "window_mode"
const VSYNC_ENABLED_KEY := "vsync_enabled"
const WINDOW_MODE_LABELS: Array[String] = [
	"Windowed",
	"Fullscreen",
]

var _window_mode: int = DEFAULT_WINDOW_MODE
var _vsync_enabled: bool = DEFAULT_VSYNC_ENABLED


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	load_display_settings()


func get_window_mode() -> int:
	return _window_mode


func set_window_mode(value: int, save_settings: bool = true) -> void:
	_window_mode = clampi(value, WindowMode.WINDOWED, WindowMode.FULLSCREEN)
	_apply_window_mode()
	if save_settings:
		_save_display_settings()


func get_vsync_enabled() -> bool:
	return _vsync_enabled


func set_vsync_enabled(value: bool, save_settings: bool = true) -> void:
	_vsync_enabled = value
	_apply_vsync_mode()
	if save_settings:
		_save_display_settings()


func reset_display_settings() -> void:
	_window_mode = _get_default_window_mode()
	_vsync_enabled = DEFAULT_VSYNC_ENABLED
	_apply_window_mode()
	_apply_vsync_mode()
	_save_display_settings()


func load_display_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_FILE_PATH)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		push_warning("Failed to load display settings from '%s' (error %s)." % [SETTINGS_FILE_PATH, error])

	_window_mode = clampi(int(config.get_value(SETTINGS_SECTION, WINDOW_MODE_KEY, _get_default_window_mode())), WindowMode.WINDOWED, WindowMode.FULLSCREEN)
	_vsync_enabled = bool(config.get_value(SETTINGS_SECTION, VSYNC_ENABLED_KEY, DEFAULT_VSYNC_ENABLED))
	_apply_window_mode()
	_apply_vsync_mode()


func get_window_mode_labels() -> Array[String]:
	return WINDOW_MODE_LABELS.duplicate()


func _get_default_window_mode() -> int:
	var default_window_mode := int(ProjectSettings.get_setting_with_override(DEFAULT_WINDOW_MODE_SETTING))
	return clampi(default_window_mode, WindowMode.WINDOWED, WindowMode.FULLSCREEN)


func _apply_window_mode() -> void:
	match _window_mode:
		WindowMode.WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			_apply_windowed_size()
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _apply_windowed_size() -> void:
	DisplayServer.window_set_size(DEFAULT_WINDOW_SIZE)
	_center_window()


func _apply_vsync_mode() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if _vsync_enabled else DisplayServer.VSYNC_DISABLED)


func _center_window() -> void:
	var screen := DisplayServer.window_get_current_screen()
	var screen_position := DisplayServer.screen_get_position(screen)
	var screen_size := DisplayServer.screen_get_size(screen)
	var centered_offset := Vector2(screen_size - DEFAULT_WINDOW_SIZE) * 0.5
	var centered_position := screen_position + Vector2i(roundi(centered_offset.x), roundi(centered_offset.y))
	DisplayServer.window_set_position(centered_position)


func _save_display_settings() -> void:
	var config := ConfigFile.new()
	var load_error := config.load(SETTINGS_FILE_PATH)
	if load_error != OK and load_error != ERR_FILE_NOT_FOUND:
		push_warning("Failed to load existing settings from '%s' before saving display settings (error %s)." % [SETTINGS_FILE_PATH, load_error])

	config.set_value(SETTINGS_SECTION, WINDOW_MODE_KEY, _window_mode)
	config.set_value(SETTINGS_SECTION, VSYNC_ENABLED_KEY, _vsync_enabled)

	var save_error := config.save(SETTINGS_FILE_PATH)
	if save_error != OK:
		push_warning("Failed to save display settings to '%s' (error %s)." % [SETTINGS_FILE_PATH, save_error])
