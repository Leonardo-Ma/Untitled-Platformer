extends Node


func _ready() -> void:
	LevelManager.initialize_level(self)
	SoundManager.change_music_state(MusicController.MusicState.EXPLORATION, false, "blossom")
