extends Node3D


func _ready() -> void:
	PauseManager.set_pause_allowed(true)
	SoundManager.stop_music(0.25)
	GameManager.reset_loop_state()


func _exit_tree() -> void:
	PauseManager.set_pause_allowed(false)
	GameManager.reset_loop_state()
