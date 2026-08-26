extends Control

signal back_requested

const MenuAudio := preload("res://src/ui/menu_audio.gd")

enum BackMode {
	MAIN_MENU,
	SIGNAL_ONLY,
}

@export var back_mode: BackMode = BackMode.MAIN_MENU
@export var play_menu_music_on_ready := true

@onready var _master_volume_slider: HSlider = %MasterVolumeSlider
@onready var _music_volume_slider: HSlider = %MusicVolumeSlider
@onready var _sfx_volume_slider: HSlider = %SfxVolumeSlider
@onready var _window_mode_option: OptionButton = %WindowModeOption
@onready var _vsync_check_box: CheckBox = %VSyncCheckBox
@onready var _reset_defaults_button: Button = %ResetDefaultsButton
@onready var _back_button: Button = %BackButton


func _ready() -> void:
	if back_mode == BackMode.MAIN_MENU:
		PauseManager.set_pause_allowed(false)

	if play_menu_music_on_ready:
		MenuAudio.play_menu_music()

	_initialize_audio_sliders()
	_initialize_visual_controls()
	MenuAudio.wire_buttons([_window_mode_option, _vsync_check_box])
	MenuAudio.wire_hovers([_master_volume_slider, _music_volume_slider, _sfx_volume_slider])
	MenuAudio.wire_buttons([_reset_defaults_button, _back_button], MenuAudio.UI_HOVER, null)
	_reset_defaults_button.pressed.connect(_on_reset_defaults_pressed)
	_back_button.pressed.connect(_on_back_pressed)
	_back_button.grab_focus()


func _initialize_audio_sliders() -> void:
	_configure_volume_slider(_master_volume_slider)
	_configure_volume_slider(_music_volume_slider)
	_configure_volume_slider(_sfx_volume_slider)

	_refresh_audio_controls()

	_master_volume_slider.value_changed.connect(_apply_master_volume)
	_music_volume_slider.value_changed.connect(_apply_music_volume)
	_sfx_volume_slider.value_changed.connect(_apply_sfx_volume)
	_sfx_volume_slider.drag_ended.connect(_on_sfx_volume_drag_ended)


func _configure_volume_slider(slider: HSlider) -> void:
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 10.0
	slider.tick_count = 11
	slider.ticks_on_borders = true


func _initialize_visual_controls() -> void:
	_populate_window_modes()
	_refresh_visual_controls()

	_window_mode_option.item_selected.connect(_on_window_mode_selected)
	_vsync_check_box.toggled.connect(_on_vsync_toggled)


func _populate_window_modes() -> void:
	_window_mode_option.clear()
	var labels := DisplaySettingsManager.get_window_mode_labels()
	for index in labels.size():
		_window_mode_option.add_item(str(labels[index]), index)


func _refresh_visual_controls() -> void:
	_window_mode_option.select(DisplaySettingsManager.get_window_mode())
	_vsync_check_box.set_pressed_no_signal(DisplaySettingsManager.get_vsync_enabled())


func _refresh_audio_controls() -> void:
	_master_volume_slider.value = SoundManager.get_master_volume() * 100.0
	_music_volume_slider.value = SoundManager.get_music_volume() * 100.0
	_sfx_volume_slider.value = SoundManager.get_sfx_volume() * 100.0


func _apply_master_volume(value: float) -> void:
	SoundManager.set_master_volume(value / 100.0)


func _apply_music_volume(value: float) -> void:
	SoundManager.set_music_volume(value / 100.0)


func _apply_sfx_volume(value: float) -> void:
	SoundManager.set_sfx_volume(value / 100.0)


func _on_sfx_volume_drag_ended(_value_changed: bool) -> void:
	MenuAudio.play_sfx(MenuAudio.UI_CONFIRM)


func _on_window_mode_selected(index: int) -> void:
	DisplaySettingsManager.set_window_mode(index)
	_refresh_visual_controls()


func _on_vsync_toggled(button_pressed: bool) -> void:
	DisplaySettingsManager.set_vsync_enabled(button_pressed)


func _on_reset_defaults_pressed() -> void:
	SoundManager.reset_audio_volumes()
	DisplaySettingsManager.reset_display_settings()
	_refresh_audio_controls()
	_refresh_visual_controls()
	MenuAudio.play_sfx(MenuAudio.UI_CONFIRM)


func _on_back_pressed() -> void:
	MenuAudio.play_sfx(MenuAudio.UI_BACK)
	back_requested.emit()

	if back_mode == BackMode.SIGNAL_ONLY:
		return

	SceneNavigator.go_to_main_menu()
