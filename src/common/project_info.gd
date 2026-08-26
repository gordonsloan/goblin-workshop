extends RefCounted

const DEFAULT_PROJECT_NAME := "Godot Project"
const DEFAULT_PROJECT_VERSION := "0.2.0"
const DEFAULT_CREATOR_HANDLE := "Nodrogagon"
const PROJECT_NAME_SETTING := "application/config/name"
const PROJECT_VERSION_SETTING := "application/config/version"
const CREATOR_HANDLE_SETTING := "starter_template/credits/creator_handle"


static func get_project_name() -> String:
	return str(ProjectSettings.get_setting(PROJECT_NAME_SETTING, DEFAULT_PROJECT_NAME))


static func get_project_version() -> String:
	return str(ProjectSettings.get_setting(PROJECT_VERSION_SETTING, DEFAULT_PROJECT_VERSION))


static func get_version_label() -> String:
	return "v%s" % get_project_version()


static func get_creator_handle() -> String:
	return str(ProjectSettings.get_setting(CREATOR_HANDLE_SETTING, DEFAULT_CREATOR_HANDLE))


static func get_creator_credit() -> String:
	return "Created by %s" % get_creator_handle()
