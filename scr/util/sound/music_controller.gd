class_name MusicController
extends Node

enum MusicState {
	EXPLORATION,
	COMBAT,
	DUNGEON,
	BOSS,
	TOWN,
	NIGHT,
	SILENCE,
}

# TODO Change this to use uid
var music_library: Dictionary = {
	MusicState.EXPLORATION: preload("uid://d30ibn7723bcm"),  # src/common/audio/music/the_last_encounter_collection/tle_digital_loop_long
	#MusicState.COMBAT: preload("res://audio/music/combat.ogg"),
	#MusicState.DUNGEON: preload("res://audio/music/dungeon.ogg"),
	#MusicState.BOSS: preload("res://audio/music/boss.ogg"),
	#MusicState.TOWN: preload("res://audio/music/town.ogg"),
	#MusicState.NIGHT: preload("res://audio/music/night.ogg"),
}

var current_state: MusicState = MusicState.EXPLORATION
var current_track: AudioStream
var is_playing: bool = false

var _current_player: AudioStreamPlayer
var _fade_tween: Tween
var _transition_cooldown: bool = false
var _sound_pool: SoundPool
var _crossfade_duration: float = 2.0


func initialize(pool: SoundPool) -> void:
	_sound_pool = pool
	_create_music_player()


func _create_music_player() -> void:
	_current_player = AudioStreamPlayer.new()
	_current_player.bus = "Music"
	_current_player.volume_db = -10  # Default music volume
	add_child(_current_player)


# Public API
func play(track: AudioStream, fade_duration: float = 1.0) -> void:
	if _current_player.stream == track and _current_player.playing:
		return  # Already playing this track

	current_track = track

	if _fade_tween:
		_fade_tween.kill()

	var new_player: AudioStreamPlayer = AudioStreamPlayer.new()
	new_player.bus = "Music"
	new_player.stream = track
	new_player.volume_db = -80  # Start silent
	add_child(new_player)
	new_player.play()
	is_playing = true

	# Crossfade to new player
	_fade_tween = create_tween()
	_fade_tween.tween_property(new_player, "volume_db", _current_player.volume_db, fade_duration)
	_fade_tween.parallel().tween_property(_current_player, "volume_db", -80, fade_duration)
	_fade_tween.tween_callback(_cleanup_old_player.bind(_current_player))

	_current_player = new_player


func change_state(new_state: MusicState, immediate: bool = false) -> void:
	if new_state == current_state:
		return

	if _transition_cooldown and not immediate:
		return

	current_state = new_state

	if new_state == MusicState.SILENCE:
		stop()
		return

	var track: AudioStream = music_library.get(new_state)
	if track:
		var fade_duration: float = 0.0 if immediate else _crossfade_duration
		play(track, fade_duration)

		# Prevent state change spam
		_transition_cooldown = true
		await get_tree().create_timer(1.0).timeout
		_transition_cooldown = false


func stop(fade_duration: float = 1.0) -> void:
	if not is_playing:
		return

	if _fade_tween:
		_fade_tween.kill()

	_fade_tween = create_tween()
	_fade_tween.tween_property(_current_player, "volume_db", -80, fade_duration)
	_fade_tween.tween_callback(_stop_current_player)
	is_playing = false


func set_volume(volume_db: float) -> void:
	_current_player.volume_db = volume_db


func set_crossfade_duration(duration: float) -> void:
	_crossfade_duration = duration


# Region-based music (for open world)
func on_enter_region(region_type: String) -> void:
	match region_type:
		"dungeon":
			change_state(MusicState.DUNGEON)
		"town":
			change_state(MusicState.TOWN)
		"boss_area":
			change_state(MusicState.BOSS)
		_:
			change_state(MusicState.EXPLORATION)


func on_combat_started() -> void:
	change_state(MusicState.COMBAT)


func on_combat_ended() -> void:
	change_state(MusicState.EXPLORATION)


# Private helpers
func _cleanup_old_player(old_player: AudioStreamPlayer) -> void:
	old_player.stop()
	old_player.queue_free()


func _stop_current_player() -> void:
	_current_player.stop()
