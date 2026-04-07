extends Node

enum SoundCategory { MUSIC, SFX, AMBIENT, UI, VOICE }

var music: MusicController
var combat: CombatPrioritySoundController
var pool: SoundPool


func _ready() -> void:
	_create_subsystems()

	combat.initialize(pool)
	music.initialize(pool)

	# Optional: Load saved volume settings
	_load_volume_settings()


func _create_subsystems() -> void:
	pool = SoundPool.new()
	pool.name = "SoundPool"
	add_child(pool)

	music = MusicController.new()
	music.name = "MusicController"
	add_child(music)

	combat = CombatPrioritySoundController.new()
	combat.name = "CombatPrioritySoundController"
	add_child(combat)


# ============== PUBLIC API FOR GAME CODE ==============


# Basic sound playback
func play_sound(sound: AudioStream, category: SoundCategory, position: Vector2 = Vector2.ZERO) -> void:
	pool.play_sound(sound, category, position)


# Combat-specific with priority
func play_combat_sound(sound: AudioStream, position: Vector2, priority: int = 0) -> void:
	combat.play_with_priority(sound, position, priority)


# Music control
func play_music(track: AudioStream, fade_duration: float = 1.0) -> void:
	music.play(track, fade_duration)


func change_music_state(state: MusicController.MusicState, immediate: bool = false) -> void:
	music.change_state(state, immediate)


func stop_music(fade_duration: float = 1.0) -> void:
	music.stop(fade_duration)


# Volume control
func set_category_volume(category: SoundCategory, volume_db: float) -> void:
	var bus_name: String = _get_bus_for_category(category)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), volume_db)
	_save_volume_settings()


func get_category_volume(category: SoundCategory) -> float:
	var bus_name: String = _get_bus_for_category(category)
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))


# Global controls
func mute_all() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)


func unmute_all() -> void:
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)


func pause_all_sfx(paused: bool) -> void:
	pool.pause_category(SoundCategory.SFX, paused)
	pool.pause_category(SoundCategory.AMBIENT, paused)
	pool.pause_category(SoundCategory.VOICE, paused)


# ============== PRIVATE HELPERS ==============


func _get_bus_for_category(category: SoundCategory) -> String:
	match category:
		SoundCategory.MUSIC:
			return "Music"
		SoundCategory.SFX:
			return "SFX"
		SoundCategory.AMBIENT:
			return "Ambient"
		SoundCategory.UI:
			return "UI"
		SoundCategory.VOICE:
			return "Voice"
		_:
			return "Master"


func _load_volume_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load("user://audio_settings.cfg") == OK:
		for category: int in SoundCategory.values():
			var bus: String = _get_bus_for_category(category)
			var volume: float = config.get_value("volumes", bus, 0.0)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), volume)


func _save_volume_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	for category: int in SoundCategory.values():
		var bus: String = _get_bus_for_category(category)
		var volume: float = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus))
		config.set_value("volumes", bus, volume)
	config.save("user://audio_settings.cfg")
