## Logic for selecting next procedural level based on constraints
class_name ChunkSelector
extends RefCounted

const MAX_VERTICAL_DEVIATION: float = 300.0
const MIN_VERTICAL_DEVIATION: float = -40.0
const SKILL_UNLOCK_SCORE_STEP: int = 50

var _rng: RandomNumberGenerator
var _all_chunks: Array[ChunkData]
var _recent_chunk_paths: Array[String] = []
var _chunks_since_turn: int = 5
var _last_skill_score_threshold: int = 0
var _spawned_skills: Dictionary = {}


func _init(rng: RandomNumberGenerator, all_chunks: Array[ChunkData]) -> void:
	_rng = rng
	_all_chunks = all_chunks


func reset() -> void:
	_recent_chunk_paths.clear()
	_chunks_since_turn = 5
	_last_skill_score_threshold = 0
	_spawned_skills.clear()


func select_chunk_data(target_transform: Transform3D, skills: Dictionary, current_score: int) -> ChunkData:
	var valid_pool: Array[ChunkData] = []
	var strict_pool: Array[ChunkData] = []
	var current_y_height: float = target_transform.origin.y
	var force_skill_unlock: bool = current_score >= _last_skill_score_threshold + SKILL_UNLOCK_SCORE_STEP

	print("\n==================== Chunk Selection Debug ====================")
	print("Target Y: ", current_y_height, " | Chunks since turn: ", _chunks_since_turn, " | Last skill score unlock: ", _last_skill_score_threshold)
	print("Force skill unlock: ", force_skill_unlock)
	print("Recent paths: ", _recent_chunk_paths)

	for data: ChunkData in _all_chunks:
		# --------------- skill unlock filtering ---------------
		if data.unlocks_skill != LevelChunk.Skill.NONE:
			if not force_skill_unlock:
				continue
			var skill_name: String = LevelChunk.Skill.keys()[data.unlocks_skill].to_lower()

			if skills.get(skill_name, false) or _spawned_skills.get(skill_name, false):
				continue
		else:
			if force_skill_unlock:
				continue

		# --------------- required skills check ---------------
		var reject_reason: String = ""
		if data.requires_multi_jump and not skills.get("multi_jump", false):
			reject_reason += "missing multi_jump "
			continue
		if data.requires_dash and not skills.get("dash", false):
			reject_reason += "missing dash "

			continue
		if data.requires_teleport and not skills.get("teleport", false):
			reject_reason += "missing teleport "
			continue
		if data.requires_slow_fall and not skills.get("slow_fall", false):
			reject_reason += "missing slow_fall "
			continue
		if reject_reason:
			print("  ✗ REJECTED [%s]: %s" % [data.scene_path.get_file(), reject_reason])

		# Prevent back-to-back turns
		if data.is_turn and _chunks_since_turn < 5:
			continue

		valid_pool.push_back(data)

		# Prevent level from going too high or too low
		if current_y_height + data.height_shift > MAX_VERTICAL_DEVIATION and data.height_shift > 0:
			print("  ✗ STRICT-REJECTED [%s]: would exceed MAX_VERTICAL_DEVIATION" % data.scene_path.get_file())
			continue
		if current_y_height + data.height_shift < MIN_VERTICAL_DEVIATION and data.height_shift < 0:
			print("  ✗ STRICT-REJECTED [%s]: would exceed MIN_VERTICAL_DEVIATION" % data.scene_path.get_file())
			continue

		strict_pool.push_back(data)

	print("Pool sizes → valid: %d, strict: %d, total available: %d" % [valid_pool.size(), strict_pool.size(), _all_chunks.size()])

	# Soft fallbacks
	if strict_pool.size() > 0:
		print("  → Using STRICT pool")
		valid_pool = strict_pool
	elif valid_pool.size() == 0:
		print("  → EMERGENCY FALLBACK: using all basic chunks")
		valid_pool = _all_chunks.filter(func(d: ChunkData) -> bool: return d.unlocks_skill == LevelChunk.Skill.NONE)
		# If everything fails
		if valid_pool.size() == 0:
			valid_pool = _all_chunks
	else:
		print("  → Using BASIC valid pool (some chunks may violate vertical/AABB)")

	# Avoid recent chunks
	var non_recent: Array[ChunkData] = valid_pool.filter(func(d: ChunkData) -> bool: return not d.scene_path in _recent_chunk_paths)
	if non_recent.size() > 0:
		print("  → Filtered out recent chunks, %d remain" % non_recent.size())
		valid_pool = non_recent
	else:
		print("  → WARNING: All valid chunks were recent! Relaxing filter to exclude only last chunk")
		var non_last: Array[ChunkData] = valid_pool.filter(
			func(d: ChunkData) -> bool: return _recent_chunk_paths.size() == 0 or d.scene_path != _recent_chunk_paths.back()
		)
		if non_last.size() > 0:
			valid_pool = non_last

	var random_idx: int = _rng.randi_range(0, valid_pool.size() - 1)
	var chosen_data: ChunkData = valid_pool[random_idx]

	if chosen_data.unlocks_skill != LevelChunk.Skill.NONE:
		var skill_name: String = LevelChunk.Skill.keys()[chosen_data.unlocks_skill].to_lower()
		_spawned_skills[skill_name] = true

	print("  ✓ SELECTED: [%s] (is_turn: %s, height_shift: %.1f)" % [chosen_data.scene_path.get_file(), chosen_data.is_turn, chosen_data.height_shift])
	print("====================================================\n")

	if force_skill_unlock:
		_last_skill_score_threshold += SKILL_UNLOCK_SCORE_STEP

	_recent_chunk_paths.push_back(chosen_data.scene_path)
	if _recent_chunk_paths.size() > 5:
		_recent_chunk_paths.pop_front()

	if chosen_data.is_turn:
		_chunks_since_turn = 0
	else:
		_chunks_since_turn += 1

	return chosen_data
