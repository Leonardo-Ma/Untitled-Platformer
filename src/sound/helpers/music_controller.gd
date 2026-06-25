# TODO: Improve methods and variables names
# TODO: Double check if AudioStreamPlayers are being freed properly
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
# TODO Maybe an export instead?
const _TRANSITION_COOLDOWN_DURATION: float = 1.0

var music_library: Dictionary = {
	MusicState.EXPLORATION:
	{
		"start": preload("uid://bxyvub1x8yjhp"),  # start.mp3
		"blossom": preload("uid://cp0si1iqrye43"),  # blossom.mp3
		"journey": preload("uid://bqcm6jip7ppr1"),  # journey.mp3
		"regrowth_wip": preload("uid://dhkwf2sf675tb"),  # regrowth_wip.mp3
		"shop": preload("uid://cewvxcw8hwrj1"),  # shop.mp3
		"town": preload("uid://bbdc8a1gy34l"),  # town.mp3
	},
	#MusicState.COMBAT: {"default": preload()},
	#MusicState.DUNGEON: {"default": preload()},
	#MusicState.BOSS: {"default": preload()},
	#MusicState.TOWN: {"default": preload()},
	#MusicState.NIGHT: {"default": preload()},
}

var current_state: MusicState = MusicState.SILENCE
var current_track: AudioStream
var is_playing: bool = false

## Two pre-created players swapped on crossfade, avoids adding child
var _player_a: AudioStreamPlayer
var _player_b: AudioStreamPlayer
var _current_player: AudioStreamPlayer
var _staging_player: AudioStreamPlayer

var _fade_tween: Tween
var _transition_cooldown: bool = false
var _sound_pool: SoundPool
var _crossfade_duration: float = 2.0


func initialize(pool: SoundPool) -> void:
	_sound_pool = pool
	_create_music_player()


func _create_music_player() -> void:
	_player_a = AudioStreamPlayer.new()
	_player_a.bus = "Music"
	_player_a.volume_db = -80.0
	add_child(_player_a)

	_player_b = AudioStreamPlayer.new()
	_player_b.bus = "Music"
	_player_b.volume_db = -80.0
	add_child(_player_b)

	_current_player = _player_a
	_staging_player = _player_b


# Public API
func play(track: AudioStream, fade_duration: float = 1.0) -> void:
	if _current_player.stream == track and _current_player.playing:
		return  # Already playing this track

	current_track = track

	if _fade_tween:
		_fade_tween.kill()

	# Disconnect finished from outgoing player before swap
	if _current_player.finished.is_connected(_on_track_finished):
		_current_player.finished.disconnect(_on_track_finished)

	var old_player: AudioStreamPlayer = _current_player
	_current_player = _staging_player
	_staging_player = old_player

	_current_player.stop()
	_current_player.stream = track
	_current_player.volume_db = -80.0
	_current_player.play()
	is_playing = true
	_current_player.finished.connect(_on_track_finished, CONNECT_ONE_SHOT)

	var fading_out: AudioStreamPlayer = _staging_player
	_fade_tween = create_tween()
	_fade_tween.tween_property(_current_player, "volume_db", 0.0, fade_duration)
	_fade_tween.parallel().tween_property(fading_out, "volume_db", -80.0, fade_duration)
	_fade_tween.tween_callback(func() -> void: fading_out.stop())


# TODO: Maybe new parameter to loop song?
func change_state(new_state: MusicState, immediate: bool = false, track_key: String = "") -> void:
	if new_state == current_state and track_key == "":
		return

	if _transition_cooldown and not immediate:
		return

	current_state = new_state

	if new_state == MusicState.SILENCE:
		stop()
		return

	var tracks: Dictionary = music_library.get(new_state, {})
	if not tracks.is_empty():
		var track: AudioStream
		if track_key != "" and tracks.has(track_key):
			track = tracks[track_key]
		else:
			track = tracks.values().pick_random()

		var fade_duration: float = 0.0 if immediate else _crossfade_duration
		play(track, fade_duration)

		# Prevent state change spam
		_transition_cooldown = true
		get_tree().create_timer(_TRANSITION_COOLDOWN_DURATION).timeout.connect(_on_transition_cooldown_finished)


func stop(fade_duration: float = 1.0) -> void:
	if not is_playing:
		return

	if _fade_tween:
		_fade_tween.kill()

	if _current_player.finished.is_connected(_on_track_finished):
		_current_player.finished.disconnect(_on_track_finished)

	_staging_player.stop()
	_staging_player.volume_db = -80.0

	var fading_out: AudioStreamPlayer = _current_player
	_fade_tween = create_tween()
	_fade_tween.tween_property(fading_out, "volume_db", -80.0, fade_duration)
	_fade_tween.tween_callback(func() -> void: fading_out.stop())
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
func _on_track_finished() -> void:
	var tracks: Dictionary = music_library.get(current_state, {})
	if not tracks.is_empty():
		var next_track: AudioStream = tracks.values().pick_random()
		play(next_track, _crossfade_duration)


func _on_transition_cooldown_finished() -> void:
	_transition_cooldown = false
