extends Node


func _ready() -> void:
	LevelManager.initialize_level(self)
	SoundManager.change_music_state(MusicController.MusicState.EXPLORATION, false, "blossom")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
