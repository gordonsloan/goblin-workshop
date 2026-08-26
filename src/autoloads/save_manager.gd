extends Node

const SAVE_VERSION: int = 1
const PROFILE_FILE_PATH := "user://profile.cfg"
const META_SECTION := "meta"
const DATA_SECTION := "data"


func save_profile(data: Dictionary) -> Error:
	var now := Time.get_datetime_string_from_system(true)
	var created_at := now

	if has_profile():
		var existing_profile := load_profile()
		created_at = str(existing_profile.get("created_at", now))

	var config := ConfigFile.new()
	config.set_value(META_SECTION, "version", SAVE_VERSION)
	config.set_value(META_SECTION, "created_at", created_at)
	config.set_value(META_SECTION, "updated_at", now)

	for key in data.keys():
		config.set_value(DATA_SECTION, str(key), data[key])

	var error := config.save(PROFILE_FILE_PATH)
	if error != OK:
		push_warning("Failed to save profile to '%s' (error %s)." % [PROFILE_FILE_PATH, error])

	return error


func load_profile() -> Dictionary:
	var config := ConfigFile.new()
	var error := config.load(PROFILE_FILE_PATH)
	if error == ERR_FILE_NOT_FOUND:
		return {}

	if error != OK:
		push_warning("Failed to load profile from '%s' (error %s)." % [PROFILE_FILE_PATH, error])
		return {}

	var data := {}
	for key in config.get_section_keys(DATA_SECTION):
		data[key] = config.get_value(DATA_SECTION, key)

	return {
		"version": int(config.get_value(META_SECTION, "version", 0)),
		"created_at": str(config.get_value(META_SECTION, "created_at", "")),
		"updated_at": str(config.get_value(META_SECTION, "updated_at", "")),
		"data": data,
	}


func has_profile() -> bool:
	return FileAccess.file_exists(PROFILE_FILE_PATH)


func delete_profile() -> Error:
	if not has_profile():
		return OK

	var directory := DirAccess.open("user://")
	if directory == null:
		var open_error := DirAccess.get_open_error()
		push_warning("Failed to open user data directory (error %s)." % open_error)
		return open_error

	var error := directory.remove("profile.cfg")
	if error != OK:
		push_warning("Failed to delete profile at '%s' (error %s)." % [PROFILE_FILE_PATH, error])

	return error


func get_profile_path() -> String:
	return PROFILE_FILE_PATH
