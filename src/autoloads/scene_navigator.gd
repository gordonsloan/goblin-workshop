extends Node

@export_file("*.tscn") var main_menu_scene_path: String = "res://src/ui/main_menu/main_menu.tscn"
@export_file("*.tscn") var settings_scene_path: String = "res://src/ui/settings_menu/settings_menu.tscn"
@export_file("*.tscn") var credits_scene_path: String = "res://src/ui/credits_menu/credits_menu.tscn"
@export_file("*.tscn") var start_scene_path: String = "res://src/scenes/levels/placeholder_scene/placeholder_scene.tscn"
@export var use_transitions: bool = true
@export_file("*.tscn") var transition_scene_path: String = "res://src/ui/transitions/fade_transition.tscn"

var _is_changing_scene: bool = false
var _transition: Node = null


func _ready() -> void:
	main_menu_scene_path = str(ProjectSettings.get_setting("scene_navigator/main_menu_scene_path", main_menu_scene_path))
	settings_scene_path = str(ProjectSettings.get_setting("scene_navigator/settings_scene_path", settings_scene_path))
	credits_scene_path = str(ProjectSettings.get_setting("scene_navigator/credits_scene_path", credits_scene_path))
	start_scene_path = str(ProjectSettings.get_setting("scene_navigator/start_scene_path", start_scene_path))
	use_transitions = bool(ProjectSettings.get_setting("scene_navigator/use_transitions", use_transitions))
	transition_scene_path = str(ProjectSettings.get_setting("scene_navigator/transition_scene_path", transition_scene_path))


func start_game() -> void:
	go_to_scene(start_scene_path)


func go_to_main_menu() -> void:
	go_to_scene(main_menu_scene_path)


func go_to_settings() -> void:
	go_to_scene(settings_scene_path)


func go_to_credits() -> void:
	go_to_scene(credits_scene_path)


func can_quit_game() -> bool:
	return not OS.has_feature("web")


func quit_game() -> void:
	if not can_quit_game():
		return

	get_tree().quit()


func go_to_scene(scene_path: String) -> void:
	if _is_changing_scene:
		return

	if scene_path.is_empty():
		push_error("Cannot change scene: scene path is empty.")
		return

	_is_changing_scene = true

	var transition := _get_transition()
	if transition != null and transition.has_method("transition_out"):
		await transition.call("transition_out")

	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to change scene to '%s' (error %s)." % [scene_path, error])
		if transition != null and transition.has_method("transition_in"):
			await transition.call("transition_in")
		_is_changing_scene = false
		return

	await get_tree().process_frame

	if transition != null and transition.has_method("transition_in"):
		await transition.call("transition_in")

	_is_changing_scene = false


func _get_transition() -> Node:
	if not use_transitions:
		return null

	if _transition != null and is_instance_valid(_transition):
		return _transition

	if transition_scene_path.is_empty():
		return null

	var packed_transition := load(transition_scene_path) as PackedScene
	if packed_transition == null:
		push_warning("Failed to load transition scene: %s" % transition_scene_path)
		return null

	_transition = packed_transition.instantiate()
	get_tree().root.add_child(_transition)
	return _transition
