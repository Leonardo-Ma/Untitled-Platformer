# BUG TODO Improve this garbage
## Manages object pooling, async loading, and sequential connecting of procedural level chunks
extends Node

# BUG: TODO: Consider if there's better approach instead of hardcore path
const CHUNK_DIRECTORIES: Array[String] = [
	"res://src/environment/levels/base_levels/",
	"res://src/environment/levels/skills/",
]
const CHUNK_SPAWN_AMOUNT: int = 8

const LEVEL_COMPLETE_SOUNDS: Array[AudioStream] = [
	preload("uid://wsw31trreg3k"),  # chequered_ink/brass_level_complete.wav
	preload("uid://c1auaooli8ysa"),  # chequered_ink/grand_piano_level_complete.wav
	preload("uid://mihwryxscya7"),  # chequered_ink/harpsichord_level_complete.wav
	preload("uid://b5ebce6j3jc7o"),  # chequered_ink/music_box_level_complete.wav
	preload("uid://cmtn3755bxxon"),  # chequered_ink/sitar_level_complete.wav
	preload("uid://bkvgbgxainyo1"),  # chequered_ink/steel_drums_level_complete.wav
	preload("uid://d4kb4jp777v37"),  # chequered_ink/synth_bass_level_complete.wav
	preload("uid://dl6cgw48oqc0y"),  # chequered_ink/vibraphone_level_complete.wav
	preload("uid://b0bvycxcrnugp")  # chequered_ink/xylophone_level_complete.wa
]

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _all_chunks: Array[ChunkData] = []
var _active_chunks: Array[LevelChunk] = []
var _chunk_pool: Dictionary = {}  # Key: String (scene_path), Value: Array[LevelChunk]
var _chunk_selector: ChunkSelector
var _chunk_exit_connections: Dictionary = {}


func _ready() -> void:
	_load_chunk_metadata_from_disk()

	# Try to fetch the global seed, else random
	var target_seed: int = GameEvents.procedural_seed if GameEvents.procedural_seed != 0 else Time.get_ticks_msec()
	_rng.seed = target_seed


func _load_chunk_metadata_from_disk() -> void:
	for dir_path: String in CHUNK_DIRECTORIES:
		var dir: DirAccess = DirAccess.open(dir_path)
		if dir:
			dir.list_dir_begin()
			var file_name: String = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					if file_name.ends_with(".tscn") or file_name.ends_with(".tscn.remap"):
						var clean_name: String = file_name.trim_suffix(".remap")
						var full_path: String = dir_path + clean_name

						# Sync load once at startup just to read the metadata/skills required.
						# Ideally, this metadata would be in a separate Resource (.tres) to avoid loading the full scene.
						var scene: PackedScene = load(full_path) as PackedScene
						if scene:
							var chunk: LevelChunk = scene.instantiate() as LevelChunk
							if chunk:
								var checkpoints: Array[Node] = chunk.find_children("*", "Checkpoint", true, false)
								var data: ChunkData = ChunkData.new()
								data.has_checkpoint = checkpoints.size() > 0

								var entrance_trigger: Node3D = chunk.get_node("%EntranceTrigger")
								var exit_trigger: Node3D = chunk.get_node("%ExitTrigger")
								data.height_shift = exit_trigger.position.y - entrance_trigger.position.y
								data.entrance_transform = chunk.transform.affine_inverse() * entrance_trigger.transform
								var in_z: Vector3 = entrance_trigger.transform.basis.z.normalized()
								var out_z: Vector3 = exit_trigger.transform.basis.z.normalized()
								data.is_turn = in_z.angle_to(out_z) > 0.1

								data.scene_path = full_path
								data.requires_multi_jump = chunk.requires_multi_jump
								data.requires_ground_dash = chunk.requires_ground_dash
								data.requires_air_dash = chunk.requires_air_dash
								data.requires_teleport = chunk.requires_teleport
								data.requires_slow_fall = chunk.requires_slow_fall
								data.unlocks_skill = chunk.unlocks_skill
								data.score_multiplier = chunk.score_multiplier

								data.difficulty_points = _get_difficulty_points(chunk, data)
								data.skill_points = _count_required_skills(data) * 2

								_all_chunks.push_back(data)

								# Start async loading the scene so it's ready in memory when needed
								ResourceLoader.load_threaded_request(full_path)

								chunk.free()
				file_name = dir.get_next()
	assert(_all_chunks.size() > 0, "No valid LevelChunks found in directories.")
	_chunk_selector = ChunkSelector.new(_rng, _all_chunks)


func _get_difficulty_points(chunk: LevelChunk, data: ChunkData) -> int:
	match chunk.difficulty:
		LevelChunk.Difficulty.EASY:
			return 10
		LevelChunk.Difficulty.MEDIUM:
			return 30
		LevelChunk.Difficulty.HARD:
			return 50

	assert(false, "Difficulty not found for this level chunk " + data.scene_path)
	return 0


func _count_required_skills(data: ChunkData) -> int:
	var required_skills: Array[bool] = [
		data.requires_multi_jump,
		data.requires_ground_dash,
		data.requires_air_dash,
		data.requires_teleport,
		data.requires_slow_fall,
	]
	var count: int = 0
	for required: bool in required_skills:
		if required:
			count += 5
	return count


func _get_chunk_data_by_path(path: String) -> ChunkData:
	for data: ChunkData in _all_chunks:
		if data.scene_path == path:
			return data
	return null


## Reset pool when the reload or exit
func clear_level() -> void:
	for chunk: LevelChunk in _active_chunks:
		if is_instance_valid(chunk):
			_pool_chunk(chunk)
	_active_chunks.clear()
	if _chunk_selector:
		_chunk_selector.reset()


func _get_player_skills() -> Dictionary:
	var player: Node = get_tree().get_first_node_in_group(Groups.PLAYERS)
	assert(player != null, "Player missing in " + self.name)
	return player.get_skills()


## Load chunks to be kept in memory, save them in active chunks
func initialize_level(parent_world: Node) -> void:
	assert(_all_chunks.size() > 0, "No chunks available in LevelManager AutoLoad " + self.name)
	clear_level()

	var next_spawn_transform: Transform3D = Transform3D()

	for i: int in range(CHUNK_SPAWN_AMOUNT):
		var chunk_instance: LevelChunk = _get_random_valid_chunk(next_spawn_transform)

		# If chunk was pooled, it might already be in the tree, otherwise add it
		if chunk_instance.get_parent() != parent_world:
			if chunk_instance.get_parent() != null:
				chunk_instance.get_parent().remove_child(chunk_instance)
			parent_world.add_child(chunk_instance)

		chunk_instance.process_mode = Node.PROCESS_MODE_INHERIT
		chunk_instance.visible = true
		_align_chunk_to_transform(chunk_instance, next_spawn_transform)
		_active_chunks.push_back(chunk_instance)

		_setup_chunk_trigger(chunk_instance, parent_world)

		next_spawn_transform = chunk_instance.get_node("%ExitTrigger").global_transform


func _align_chunk_to_transform(chunk: LevelChunk, target_transform: Transform3D) -> void:
	var entrance_node: Node3D = chunk.get_node("%EntranceTrigger")

	# Snap position and maintain the chunk native rotation
	var rel_entrance: Transform3D = chunk.global_transform.affine_inverse() * entrance_node.global_transform
	chunk.global_transform = target_transform * rel_entrance.affine_inverse()


func _setup_chunk_trigger(chunk: LevelChunk, parent_world: Node) -> void:
	var trigger: Area3D = chunk.get_node("%ExitTrigger")
	_disconnect_chunk_trigger(chunk)
	var callable: Callable = _on_chunk_exit_reached.bind(parent_world, chunk)
	_chunk_exit_connections[chunk.get_instance_id()] = callable
	trigger.body_entered.connect(callable)


func _on_chunk_exit_reached(body: Node3D, parent_world: Node, passed_chunk: LevelChunk) -> void:
	if not body.is_in_group(Groups.PLAYERS):
		return

	if not passed_chunk.has_meta("scored"):
		passed_chunk.set_meta("scored", true)
		SoundManager.play_sound(LEVEL_COMPLETE_SOUNDS.pick_random() as AudioStream, SoundManager.SoundCategory.SFX, body.global_position)
		var chunk_path: String = passed_chunk.scene_file_path
		for data: ChunkData in _all_chunks:
			if data.scene_path == chunk_path:
				var total_score: int = roundi((data.difficulty_points + data.skill_points) * data.score_multiplier)
				GameEvents.add_score(total_score)
				break

	# Only start recycling after the third chunk
	if _active_chunks.size() > 2 and _active_chunks[2] == passed_chunk:
		recycle_oldest_chunk(parent_world)


## Triggers by exit trigger world collision boundary
func recycle_oldest_chunk(parent_world: Node) -> void:
	assert(not _active_chunks.is_empty(), "Cannot recycle empty pool in " + self.name)

	var oldest: LevelChunk = _active_chunks.pop_front()
	var newest: LevelChunk = _active_chunks.back()

	_pool_chunk(oldest)

	var target_transform: Transform3D = newest.get_node("%ExitTrigger").global_transform
	var next_chunk: LevelChunk = _get_random_valid_chunk(target_transform)
	if next_chunk.get_parent() != parent_world:
		if next_chunk.get_parent() != null:
			next_chunk.get_parent().remove_child(next_chunk)
		parent_world.add_child(next_chunk)

	# Snap the new chunk to the exit trigger of the current newest
	next_chunk.process_mode = Node.PROCESS_MODE_INHERIT
	next_chunk.visible = true
	_align_chunk_to_transform(next_chunk, target_transform)

	_active_chunks.push_back(next_chunk)
	_setup_chunk_trigger(next_chunk, parent_world)


func _pool_chunk(chunk: LevelChunk) -> void:
	# Disable processing and hide the chunk to save performance
	_disconnect_chunk_trigger(chunk)
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
	chunk.visible = false
	if chunk.has_meta("scored"):
		chunk.remove_meta("scored")

	if chunk.get_parent() != null:
		chunk.get_parent().remove_child(chunk)

	# Keep a reference to its original scene path to fetch it later
	var path: String = chunk.scene_file_path
	if not _chunk_pool.has(path):
		_chunk_pool[path] = []
	_chunk_pool[path].push_back(chunk)


func _disconnect_chunk_trigger(chunk: LevelChunk) -> void:
	var chunk_id: int = chunk.get_instance_id()
	if not _chunk_exit_connections.has(chunk_id):
		return

	var trigger: Area3D = chunk.get_node("%ExitTrigger")
	var callable: Callable = _chunk_exit_connections[chunk_id]
	if trigger.body_entered.is_connected(callable):
		trigger.body_entered.disconnect(callable)
	_chunk_exit_connections.erase(chunk_id)


func _get_random_valid_chunk(target_transform: Transform3D) -> LevelChunk:
	var skills: Dictionary = _get_player_skills()
	var chosen_data: ChunkData = _chunk_selector.select_chunk_data(target_transform, skills, GameEvents.player_score)
	if _chunk_pool.has(chosen_data.scene_path) and not _chunk_pool[chosen_data.scene_path].is_empty():
		return _chunk_pool[chosen_data.scene_path].pop_back()
	var scene: PackedScene
	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(chosen_data.scene_path)
	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		scene = ResourceLoader.load_threaded_get(chosen_data.scene_path) as PackedScene
	else:
		scene = load(chosen_data.scene_path) as PackedScene
	return scene.instantiate() as LevelChunk
