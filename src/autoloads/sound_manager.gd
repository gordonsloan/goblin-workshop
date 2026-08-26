extends Node

@export_range(1, 64, 1) var sfx_pool_size: int = 8
@export var master_bus_name: StringName = &"Master"
@export var music_bus_name: StringName = &"Music"
@export var sfx_bus_name: StringName = &"SFX"

const DEFAULT_MASTER_VOLUME: float = 1.0
const DEFAULT_MUSIC_VOLUME: float = 1.0
const DEFAULT_SFX_VOLUME: float = 1.0
const MIN_VOLUME_DB: float = -80.0
const VOLUME_STEP_COUNT: int = 10
const SETTINGS_FILE_PATH := "user://settings.cfg"
const SETTINGS_SECTION := "audio"
const MASTER_VOLUME_KEY := "master_volume"
const MUSIC_VOLUME_KEY := "music_volume"
const SFX_VOLUME_KEY := "sfx_volume"
const VOLUME_STEP_DECIBELS: Array[float] = [
	MIN_VOLUME_DB,
	-40.0,
	-30.0,
	-25.0,
	-20.0,
	-15.0,
	-12.0,
	-9.0,
	-6.0,
	-3.0,
	0.0,
]

var _sfx_players: Array[AudioStreamPlayer] = []
var _music_players: Array[AudioStreamPlayer] = []
var _active_music_index: int = 0
var _sfx_reuse_index: int = 0
var _music_tween: Tween = null
var _master_volume: float = DEFAULT_MASTER_VOLUME
var _music_volume: float = DEFAULT_MUSIC_VOLUME
var _sfx_volume: float = DEFAULT_SFX_VOLUME


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_sfx_pool()
	_create_music_players()
	load_audio_settings()


func _exit_tree() -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()

	for audio_player in _sfx_players:
		audio_player.stop()
		audio_player.stream = null

	for audio_player in _music_players:
		audio_player.stop()
		audio_player.stream = null


func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0, pitch_randomness: float = 0.0) -> void:
	if stream == null:
		return

	var audio_player := _get_available_sfx_player()
	audio_player.stop()
	audio_player.stream = stream
	audio_player.volume_db = volume_db
	audio_player.pitch_scale = _get_randomized_pitch(pitch_scale, pitch_randomness)
	audio_player.play()


func stop_sfx() -> void:
	for audio_player in _sfx_players:
		audio_player.stop()


func play_music(stream: AudioStream, fade_duration: float = 0.5, volume_db: float = 0.0) -> void:
	if stream == null:
		return

	var active_player := _music_players[_active_music_index]
	if active_player.playing and active_player.stream == stream:
		if _music_tween != null and _music_tween.is_valid():
			_music_tween.kill()
		active_player.volume_db = volume_db
		return

	var next_index := 1 - _active_music_index
	var previous_player := active_player
	var next_player := _music_players[next_index]

	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()

	next_player.stop()
	next_player.stream = stream
	next_player.volume_db = -80.0 if fade_duration > 0.0 else volume_db
	next_player.play()

	if fade_duration <= 0.0:
		previous_player.stop()
		next_player.volume_db = volume_db
	else:
		_music_tween = create_tween()
		_music_tween.set_parallel(true)
		_music_tween.tween_property(next_player, "volume_db", volume_db, fade_duration)
		if previous_player.playing:
			_music_tween.tween_property(previous_player, "volume_db", -80.0, fade_duration)
		await _music_tween.finished
		previous_player.stop()

	_active_music_index = next_index


func stop_music(fade_duration: float = 0.5) -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()

	if fade_duration <= 0.0:
		for audio_player in _music_players:
			audio_player.stop()
		return

	var playing_players: Array[AudioStreamPlayer] = []
	for audio_player in _music_players:
		if audio_player.playing:
			playing_players.append(audio_player)

	if playing_players.is_empty():
		return

	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	for audio_player in playing_players:
		_music_tween.tween_property(audio_player, "volume_db", -80.0, fade_duration)

	await _music_tween.finished
	for audio_player in playing_players:
		audio_player.stop()


func stop_all(fade_duration: float = 0.25) -> void:
	stop_sfx()
	await stop_music(fade_duration)


func set_master_volume(value: float, save_settings: bool = true) -> void:
	_master_volume = _set_bus_volume(master_bus_name, value)
	if save_settings:
		_save_audio_settings()


func set_music_volume(value: float, save_settings: bool = true) -> void:
	_music_volume = _set_bus_volume(music_bus_name, value)
	if save_settings:
		_save_audio_settings()


func set_sfx_volume(value: float, save_settings: bool = true) -> void:
	_sfx_volume = _set_bus_volume(sfx_bus_name, value)
	if save_settings:
		_save_audio_settings()


func get_master_volume() -> float:
	return _master_volume


func get_music_volume() -> float:
	return _music_volume


func get_sfx_volume() -> float:
	return _sfx_volume


func reset_audio_volumes() -> void:
	set_master_volume(DEFAULT_MASTER_VOLUME, false)
	set_music_volume(DEFAULT_MUSIC_VOLUME, false)
	set_sfx_volume(DEFAULT_SFX_VOLUME, false)
	_save_audio_settings()


func load_audio_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_FILE_PATH)
	if error != OK and error != ERR_FILE_NOT_FOUND:
		push_warning("Failed to load audio settings from '%s' (error %s)." % [SETTINGS_FILE_PATH, error])

	set_master_volume(float(config.get_value(SETTINGS_SECTION, MASTER_VOLUME_KEY, DEFAULT_MASTER_VOLUME)), false)
	set_music_volume(float(config.get_value(SETTINGS_SECTION, MUSIC_VOLUME_KEY, DEFAULT_MUSIC_VOLUME)), false)
	set_sfx_volume(float(config.get_value(SETTINGS_SECTION, SFX_VOLUME_KEY, DEFAULT_SFX_VOLUME)), false)


func _create_sfx_pool() -> void:
	for index in range(sfx_pool_size):
		var audio_player := AudioStreamPlayer.new()
		audio_player.name = "SFXPlayer%s" % [index + 1]
		audio_player.bus = sfx_bus_name
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(audio_player)
		_sfx_players.append(audio_player)


func _create_music_players() -> void:
	for index in range(2):
		var audio_player := AudioStreamPlayer.new()
		audio_player.name = "MusicPlayer%s" % [index + 1]
		audio_player.bus = music_bus_name
		audio_player.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(audio_player)
		_music_players.append(audio_player)


func _get_available_sfx_player() -> AudioStreamPlayer:
	for audio_player in _sfx_players:
		if not audio_player.playing:
			return audio_player

	var audio_player := _sfx_players[_sfx_reuse_index]
	_sfx_reuse_index = (_sfx_reuse_index + 1) % _sfx_players.size()
	return audio_player


func _get_randomized_pitch(base_pitch: float, pitch_randomness: float) -> float:
	if pitch_randomness <= 0.0:
		return base_pitch

	var offset := randf_range(-pitch_randomness, pitch_randomness)
	return max(0.01, base_pitch + offset)


func _set_bus_volume(bus_name: StringName, value: float) -> float:
	var volume_step := _get_volume_step(value)
	var normalized_value := float(volume_step) / float(VOLUME_STEP_COUNT)
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("Audio bus '%s' does not exist." % bus_name)
		return normalized_value

	AudioServer.set_bus_mute(bus_index, volume_step == 0)
	AudioServer.set_bus_volume_db(bus_index, VOLUME_STEP_DECIBELS[volume_step])
	return normalized_value


func _get_volume_step(value: float) -> int:
	return clampi(roundi(clampf(value, 0.0, 1.0) * VOLUME_STEP_COUNT), 0, VOLUME_STEP_COUNT)


func _save_audio_settings() -> void:
	var config := ConfigFile.new()
	var load_error := config.load(SETTINGS_FILE_PATH)
	if load_error != OK and load_error != ERR_FILE_NOT_FOUND:
		push_warning("Failed to load existing settings from '%s' before saving audio settings (error %s)." % [SETTINGS_FILE_PATH, load_error])

	config.set_value(SETTINGS_SECTION, MASTER_VOLUME_KEY, _master_volume)
	config.set_value(SETTINGS_SECTION, MUSIC_VOLUME_KEY, _music_volume)
	config.set_value(SETTINGS_SECTION, SFX_VOLUME_KEY, _sfx_volume)

	var save_error := config.save(SETTINGS_FILE_PATH)
	if save_error != OK:
		push_warning("Failed to save audio settings to '%s' (error %s)." % [SETTINGS_FILE_PATH, save_error])
