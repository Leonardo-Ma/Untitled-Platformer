## Manages object pooling, async loading, and sequential connecting of procedural level chunks
extends Node


## Helper definition to cache chunk layout data at startup without constantly instantiating
class ChunkData:
	extends RefCounted
	var scene_path: String
	var requires_multi_jump: bool
	var requires_ground_dash: bool
	var requires_air_dash: bool
	var requires_teleport: bool
	var requires_slow_fall: bool


const CHUNK_DIRECTORIES: Array[String] = [
	"res://scr/world_asset/levels/easy/", "res://scr/world_asset/levels/medium/", "res://scr/world_asset/levels/hard/"
]
const CHUNK_SPAWN_AMOUNT: int = 6

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _all_chunks: Array[ChunkData] = []
var _active_chunks: Array[LevelChunk] = []
var _chunk_pool: Dictionary = {}  # Key: scene_path (String), Value: Array[LevelChunk]


func _ready() -> void:
	_load_chunk_metadata_from_disk()

	# Try to pull a deterministic seed globally set by the event bus or menu session manager
	var target_seed: int = GameEvents.procedural_seed if GameEvents.procedural_seed != 0 else Time.get_ticks_msec()
	_rng.seed = target_seed


func _load_chunk_metadata_from_disk() -> void:
	for dir_path in CHUNK_DIRECTORIES:
		var dir := DirAccess.open(dir_path)
		if dir != null:
			dir.list_dir_begin()
			var file_name: String = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					if file_name.ends_with(".tscn") or file_name.ends_with(".tscn.remap"):
						var clean_name: String = file_name.trim_suffix(".remap")
						var full_path: String = dir_path + clean_name

						# Sync load once at startup just to read the metadata/skills required.
						# Ideally, this metadata should be in a separate Resource (.tres) to avoid loading the full scene.
						var scene: PackedScene = load(full_path) as PackedScene
						if scene != null:
							var temp_instance: Node = scene.instantiate()
							if temp_instance is LevelChunk:
								var checkpoints: Array[Node] = temp_instance.find_children("*", "Checkpoint", true, false)
								assert(checkpoints.size() > 0, "LevelChunk missing Checkpoint in " + full_path)

								var data: ChunkData = ChunkData.new()
								data.scene_path = full_path
								data.requires_multi_jump = temp_instance.requires_multi_jump
								data.requires_ground_dash = temp_instance.requires_ground_dash
								data.requires_air_dash = temp_instance.requires_air_dash
								data.requires_teleport = temp_instance.requires_teleport
								data.requires_slow_fall = temp_instance.requires_slow_fall
								_all_chunks.push_back(data)

								# Start async loading the scene so it's ready in memory when needed
								ResourceLoader.load_threaded_request(full_path)

							temp_instance.free()
				file_name = dir.get_next()
	assert(_all_chunks.size() > 0, "No valid LevelChunks found in directories.")


## Reset pool when the reload or exit
func clear_level() -> void:
	for chunk in _active_chunks:
		if is_instance_valid(chunk):
			_pool_chunk(chunk)
	_active_chunks.clear()


func _get_player_skills() -> Dictionary:
	var player: Node = get_tree().get_first_node_in_group(Groups.PLAYERS)
	if player != null and player.has_method("get_skills"):
		return player.get_skills()
	return {}


## Load chunks to be kept in memory, save them in active chunks
func initialize_level(parent_world: Node) -> void:
	assert(_all_chunks.size() > 0, "No chunks available in LevelManager AutoLoad " + self.name)
	clear_level()

	var next_spawn_transform: Transform3D = Transform3D()

	for i in range(CHUNK_SPAWN_AMOUNT):
		var chunk_instance: LevelChunk = _get_random_valid_chunk()

		# If chunk was pooled, it might already be in the tree, otherwise add it
		if chunk_instance.get_parent() != parent_world:
			if chunk_instance.get_parent() != null:
				chunk_instance.get_parent().remove_child(chunk_instance)
			parent_world.add_child(chunk_instance)

		chunk_instance.global_transform = next_spawn_transform
		chunk_instance.process_mode = Node.PROCESS_MODE_INHERIT
		chunk_instance.visible = true
		_active_chunks.push_back(chunk_instance)

		_setup_chunk_trigger(chunk_instance, parent_world)

		next_spawn_transform = chunk_instance.exit_trigger.global_transform


func _setup_chunk_trigger(chunk: LevelChunk, parent_world: Node) -> void:
	var trigger: Area3D = chunk.get_node_or_null("%ExitTrigger")
	if trigger != null:
		# Disconnect previous connections if recycled
		if trigger.body_entered.is_connected(_on_chunk_exit_reached):
			trigger.body_entered.disconnect(_on_chunk_exit_reached)
		trigger.body_entered.connect(_on_chunk_exit_reached.bind(parent_world, chunk))


func _on_chunk_exit_reached(body: Node3D, parent_world: Node, passed_chunk: LevelChunk) -> void:
	if not body.is_in_group(Groups.PLAYERS):
		return

	# Only start recycling after the third chunk
	if _active_chunks.size() > 2 and _active_chunks[2] == passed_chunk:
		recycle_oldest_chunk(parent_world)


## Triggers by exit trigger world collision boundary
func recycle_oldest_chunk(parent_world: Node) -> void:
	assert(not _active_chunks.is_empty(), "Cannot recycle empty pool in " + self.name)

	var oldest: LevelChunk = _active_chunks.pop_front()
	var newest: LevelChunk = _active_chunks.back()

	_pool_chunk(oldest)

	var next_chunk: LevelChunk = _get_random_valid_chunk()
	if next_chunk.get_parent() != parent_world:
		if next_chunk.get_parent() != null:
			next_chunk.get_parent().remove_child(next_chunk)
		parent_world.add_child(next_chunk)

	# Snap the new chunk to the exit trigger of the current newest
	next_chunk.global_transform = newest.exit_trigger.global_transform
	next_chunk.process_mode = Node.PROCESS_MODE_INHERIT
	next_chunk.visible = true

	_active_chunks.push_back(next_chunk)
	_setup_chunk_trigger(next_chunk, parent_world)


func _pool_chunk(chunk: LevelChunk) -> void:
	# Disable processing and hide the chunk to save performance
	chunk.process_mode = Node.PROCESS_MODE_DISABLED
	chunk.visible = false

	# Keep a reference to its original scene path to fetch it later
	var path: String = chunk.scene_file_path
	if not _chunk_pool.has(path):
		_chunk_pool[path] = []
	_chunk_pool[path].push_back(chunk)


func _get_random_valid_chunk() -> LevelChunk:
	var skills: Dictionary = _get_player_skills()
	var valid_pool: Array[ChunkData] = []

	for data in _all_chunks:
		if data.requires_multi_jump and not skills.get("multi_jump", false):
			continue
		if data.requires_ground_dash and not skills.get("ground_dash", false):
			continue
		if data.requires_air_dash and not skills.get("air_dash", false):
			continue
		if data.requires_teleport and not skills.get("teleport", false):
			continue
		if data.requires_slow_fall and not skills.get("slow_fall", false):
			continue
		valid_pool.push_back(data)

	assert(valid_pool.size() > 0, "No chunks available matching player skills.")
	var random_idx: int = _rng.randi_range(0, valid_pool.size() - 1)
	var chosen_data: ChunkData = valid_pool[random_idx]

	# 1. Check if we have a suspended instance in the pool
	if _chunk_pool.has(chosen_data.scene_path) and not _chunk_pool[chosen_data.scene_path].is_empty():
		return _chunk_pool[chosen_data.scene_path].pop_back()

	# 2. Otherwise, fetch the asynchronously loaded scene and instantiate it
	var scene: PackedScene
	var load_status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(chosen_data.scene_path)

	if load_status == ResourceLoader.THREAD_LOAD_LOADED:
		scene = ResourceLoader.load_threaded_get(chosen_data.scene_path) as PackedScene
	else:
		# Fallback if it hasn't finished loading yet or failed
		scene = load(chosen_data.scene_path) as PackedScene

	return scene.instantiate() as LevelChunk
