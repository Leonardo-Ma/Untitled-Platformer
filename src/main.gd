class_name Main
extends Node


func _ready() -> void:
	LevelChunkManager.initialize_level()
	SoundManager.change_music_state(MusicController.MusicState.EXPLORATION, false)
