extends Node3D


func _ready() -> void:
	PauseManager.set_pause_allowed(true)
	SoundManager.stop_music(0.25)


func _exit_tree() -> void:
	PauseManager.set_pause_allowed(false)
