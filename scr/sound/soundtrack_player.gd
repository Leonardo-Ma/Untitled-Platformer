class_name soundtrackPlayerClass
extends Node

enum PlaylistTheme {PEACE,FIGHT}

# In order to add different songs to a playlist just preload them inside dictionary:
var playlist: Dictionary = {
		PlaylistTheme.PEACE: [preload("res://assets/music/main_music.ogg"), 
		preload("res://assets/music/forest_biome.ogg")],
		PlaylistTheme.FIGHT: [preload("res://assets/music/scifi_vibes_boss.ogg")]
}

var current_theme: int = PlaylistTheme.PEACE
var is_repeating: bool = true

@onready var streamPlayer: AudioStreamPlayer = $"."

func play_theme(theme: int, repeat_themes: bool = true) -> void:
	if current_theme != theme or !streamPlayer.playing:
		is_repeating = false 
		streamPlayer.stop()
		
		is_repeating = repeat_themes
		current_theme = theme
		
		var theme_tracks: Array = playlist[current_theme]
		if theme_tracks != []:
			streamPlayer.stream = theme_tracks[randi() % theme_tracks.size()]
			streamPlayer.play()

func replay_current_theme() -> void:
	var theme_tracks: Array = playlist[current_theme]
	streamPlayer.stream = theme_tracks[randi() % theme_tracks.size()]
	streamPlayer.play()

func _on_AudioStreamPlayer_finished() -> void:
	if is_repeating:
		replay_current_theme()
