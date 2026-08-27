extends Node3D


func _ready() -> void:
	PauseManager.set_pause_allowed(true)
	SoundManager.stop_music(0.25)
	GameManager.reset_loop_state()
	if DisplayServer.get_name() != "headless":
		GameManager.start_productivity_decay(90.0, 0.75)


func _exit_tree() -> void:
	PauseManager.set_pause_allowed(false)
	GameManager.reset_loop_state()
	GameManager.stop_productivity_decay()
