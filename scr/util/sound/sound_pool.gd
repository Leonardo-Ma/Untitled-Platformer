class_name SoundPool
extends Node

# Max simultaneous sounds
const CATEGORY_LIMITS = {
	SoundManager.SoundCategory.MUSIC: 1,
	SoundManager.SoundCategory.SFX: 10,
	SoundManager.SoundCategory.AMBIENT: 4,
	SoundManager.SoundCategory.UI: 3,
	SoundManager.SoundCategory.VOICE: 5,
}

# Audio buses (match these to your Godot Audio tab setup)
const BUSES = {
	SoundManager.SoundCategory.MUSIC: "Music",
	SoundManager.SoundCategory.SFX: "SFX",
	SoundManager.SoundCategory.AMBIENT: "Ambient",
	SoundManager.SoundCategory.UI: "UI",
	SoundManager.SoundCategory.VOICE: "Voice",
}

# Pools: category -> Array of available players
var _pools: Dictionary = {}
# Active players: category -> Array of currently playing players
var _active_players: Dictionary = {}


func _ready() -> void:
	_setup_pools()


func _setup_pools() -> void:
	for category in CATEGORY_LIMITS:
		_pools[category] = []
		_active_players[category] = []

		var limit = CATEGORY_LIMITS[category]
		for i in range(limit):
			var player = _create_player_for_category(category)
			add_child(player)
			_pools[category].append(player)


func _create_player_for_category(category: int) -> Node:
	# Return type is Node (common parent of both AudioStreamPlayer and AudioStreamPlayer2D)
	var player: Node

	# Use 2D players for positional sounds
	match category:
		SoundManager.SoundCategory.SFX, SoundManager.SoundCategory.AMBIENT, SoundManager.SoundCategory.VOICE:
			player = AudioStreamPlayer2D.new()
		_:  # MUSIC, UI
			player = AudioStreamPlayer.new()

	# Set bus - need to use set() since Node doesn't have .bus property
	player.set("bus", BUSES[category])
	return player


# Main playback function
func play_sound(sound: AudioStream, category: int, position: Vector2 = Vector2.ZERO) -> AudioStreamPlayer:
	# Return type can be AudioStreamPlayer since both types support the same methods
	var player = _get_available_player(category)
	if not player:
		# Pool exhausted - optionally replace oldest
		player = _replace_oldest_sound(category)
		if not player:
			return null

	# Disconnect any existing finished signals (important for recycled players)
	if player.finished.is_connected(_on_sound_finished):
		player.finished.disconnect(_on_sound_finished)

	# Configure the player
	player.stream = sound
	player.pitch_scale = 1.0
	player.stream_paused = false  # Reset paused state

	# Set position for 2D players
	if player is AudioStreamPlayer2D and position != Vector2.ZERO:
		(player as AudioStreamPlayer2D).global_position = position

	# Play and track
	player.play()
	_active_players[category].append(player)

	# Connect finished signal (use ONE_SHOT to auto-disconnect after firing)
	player.finished.connect(_on_sound_finished.bind(player, category), CONNECT_ONE_SHOT)

	return player


func _get_available_player(category: int):
	# Return type is inferred (will be AudioStreamPlayer or AudioStreamPlayer2D)
	if _pools[category].is_empty():
		return null
	return _pools[category].pop_back()


func _replace_oldest_sound(category: int):
	if _active_players[category].is_empty():
		return null

	# Stop and recycle the oldest active sound
	var oldest = _active_players[category].pop_front()

	# Disconnect signals before recycling
	if oldest.finished.is_connected(_on_sound_finished):
		oldest.finished.disconnect(_on_sound_finished)

	oldest.stop()
	oldest.stream = null
	return oldest


func _on_sound_finished(player, category: int) -> void:
	# Remove from active
	var idx = _active_players[category].find(player)
	if idx != -1:
		_active_players[category].remove_at(idx)

	# Return to pool
	player.stream = null
	_pools[category].append(player)

	# Note: Signal already auto-disconnected due to CONNECT_ONE_SHOT


# Category control
func pause_category(category: int, paused: bool) -> void:
	for player in _active_players[category]:
		if paused:
			player.stream_paused = true
		else:
			player.stream_paused = false


func stop_category(category: int) -> void:
	for player in _active_players[category]:
		# Disconnect signals before stopping
		if player.finished.is_connected(_on_sound_finished):
			player.finished.disconnect(_on_sound_finished)

		player.stop()
		player.stream = null
		_pools[category].append(player)
	_active_players[category].clear()


# Utility
func get_active_sound_count(category: int) -> int:
	return _active_players[category].size()


func is_category_full(category: int) -> bool:
	return _active_players[category].size() >= CATEGORY_LIMITS[category]
