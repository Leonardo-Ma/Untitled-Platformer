## Slot save system: slots 0-2 manual, 3-5 rotating auto-saves, slot 6 quick save
## Write to .tmp → rename to .tres, keep .bak of previous good save
extends Node

signal save_changed(slot_index: int)

const SAVE_DIR: String = "user://saves/"
const MANUAL_SLOTS: int = 3
const AUTO_SLOTS: int = 3
const QUICK_SAVE_SLOT: int = MANUAL_SLOTS + AUTO_SLOTS
const TOTAL_SLOTS: int = MANUAL_SLOTS + AUTO_SLOTS + 1
const AUTO_SAVE_INTERVAL: float = 120.0
const CURRENT_SAVE_VERSION: int = 1

const _COLLECTIBLE_MATCH_SQ: float = 0.25  # 0.5 m radius
const _ENEMY_MATCH_SQ: float = 0.25  # 0.5 m radius — spawn positions are deterministic

var _next_auto_slot: int = 0
var _auto_timer: Timer
var _pending_load_data: SaveData = null
var _consumed_collectible_positions: Array[Vector3] = []
var _killed_enemy_positions: Array[Vector3] = []
var _pending_player: PlayerEntity = null
var _pending_checkpoint: Vector3 = Vector3.ZERO


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	_next_auto_slot = _find_next_auto_slot()

	_auto_timer = Timer.new()
	_auto_timer.name = "AutoSaveTimer"
	_auto_timer.wait_time = AUTO_SAVE_INTERVAL
	_auto_timer.timeout.connect(_on_auto_save)
	add_child(_auto_timer)
	_auto_timer.start()

	GameEvents.collectible_consumed.connect(_on_collectible_consumed)
	GameEvents.enemy_killed.connect(_on_enemy_killed)

	if not GameEvents.player_spawned.is_connected(_on_player_spawned_for_load):
		GameEvents.player_spawned.connect(_on_player_spawned_for_load)


## Resets all session tracking and global stats for a clean new game
func reset_for_new_game() -> void:
	_consumed_collectible_positions.clear()
	_killed_enemy_positions.clear()
	_next_auto_slot = 0
	GameEvents.score = 0
	GameEvents.gold = 0
	GameEvents.score_updated.emit(GameEvents.score)
	GameEvents.gold_updated.emit(GameEvents.gold)


func save_to_slot(slot_index: int) -> bool:
	assert(
		slot_index >= 0 and slot_index < MANUAL_SLOTS,
		"SaveManager: manual slot must be 0–%d in %s" % [MANUAL_SLOTS - 1, name],
	)
	var player: PlayerEntity = get_tree().get_first_node_in_group(Groups.PLAYERS) as PlayerEntity
	assert(player != null, "SaveManager: no player found when saving in " + name)
	return _write_slot(slot_index, false, player)


func save_to_quick_slot() -> bool:
	var player: PlayerEntity = get_tree().get_first_node_in_group(Groups.PLAYERS) as PlayerEntity
	assert(player != null, "SaveManager: no player found for quick save in " + name)
	if player.health.current_health <= 0:
		return false
	return _write_slot(QUICK_SAVE_SLOT, false, player)


func load_from_slot(slot_index: int) -> bool:
	assert(
		slot_index >= 0 and slot_index < TOTAL_SLOTS,
		"SaveManager: slot out of range in " + name,
	)
	if not has_save(slot_index):
		return false
	var data: SaveData = _load_slot_resource(slot_index)
	if data == null:
		return false
	if data.save_version != CURRENT_SAVE_VERSION:
		if not _migrate(data):
			return false
	var player: PlayerEntity = get_tree().get_first_node_in_group(Groups.PLAYERS) as PlayerEntity
	if player == null:
		_pending_load_data = data
		return true
	_apply(data, player)
	return true


func delete_slot(slot_index: int) -> void:
	assert(
		slot_index >= 0 and slot_index < TOTAL_SLOTS,
		"SaveManager: slot out of range in " + name,
	)
	var base: String = _slot_path(slot_index)
	for suffix: String in ["", ".bak", ".tmp"]:
		var path: String = base + suffix
		if FileAccess.file_exists(path):
			_safe_remove(path)
	save_changed.emit(slot_index)


func has_save(slot_index: int) -> bool:
	var base: String = _slot_path(slot_index)
	return FileAccess.file_exists(base) or FileAccess.file_exists(base + ".bak")


func get_slot_data(slot_index: int) -> SaveData:
	if not has_save(slot_index):
		return null
	return _load_slot_resource(slot_index)


func has_any_save() -> bool:
	for i: int in range(TOTAL_SLOTS):
		if has_save(i):
			return true
	return false


func _on_collectible_consumed(pos: Vector3) -> void:
	_consumed_collectible_positions.append(pos)


func _on_enemy_killed(pos: Vector3) -> void:
	_killed_enemy_positions.append(pos)


func _on_auto_save() -> void:
	if get_tree().paused:
		return
	var player: PlayerEntity = get_tree().get_first_node_in_group(Groups.PLAYERS) as PlayerEntity
	if player == null or player.health.current_health <= 0:
		return
	var target_slot: int = MANUAL_SLOTS + _next_auto_slot
	_write_slot(target_slot, true, player)
	_next_auto_slot = (_next_auto_slot + 1) % AUTO_SLOTS


func _on_player_spawned_for_load(_player: PlayerEntity) -> void:
	if _pending_load_data == null:
		return
	var player: PlayerEntity = get_tree().get_first_node_in_group(Groups.PLAYERS) as PlayerEntity
	assert(player != null, "SaveManager: player_spawned fired but player not found in " + name)
	_apply(_pending_load_data, player)
	_pending_load_data = null


func _write_slot(slot_index: int, is_auto: bool, player: PlayerEntity) -> bool:
	var data: SaveData = _build(player, slot_index, is_auto)
	var base: String = _slot_path(slot_index)
	var tmp: String = base.replace(".tres", "_tmp.tres")
	var bak: String = base + ".bak"

	var err: int = ResourceSaver.save(data, tmp)
	if err != OK:
		push_error("SaveManager: failed writing tmp for slot %d (error %d)" % [slot_index, err])
		return false

	var verify: SaveData = ResourceLoader.load(tmp, "", ResourceLoader.CACHE_MODE_IGNORE) as SaveData
	if verify == null:
		push_error("SaveManager: tmp verification failed for slot %d, aborting commit" % slot_index)
		_safe_remove(tmp)
		return false

	if FileAccess.file_exists(base):
		if not _safe_rename(base, bak):
			_safe_remove(tmp)
			return false

	if not _safe_rename(tmp, base):
		push_error("SaveManager: failed committing save for slot %d" % slot_index)
		if FileAccess.file_exists(bak):
			_safe_rename(bak, base)
		return false

	print_debug("Saved slot ", slot_index)
	save_changed.emit(slot_index)
	return true


func _build(player: PlayerEntity, slot_index: int, is_auto: bool) -> SaveData:
	var data: SaveData = SaveData.new()
	data.save_version = CURRENT_SAVE_VERSION
	data.slot_index = slot_index
	data.is_auto_save = is_auto
	data.save_timestamp = int(Time.get_unix_time_from_system())

	data.score = GameEvents.score
	data.gold = GameEvents.gold
	data.player_health = clampi(player.health.current_health, 0, player.health.max_health)
	data.unlocked_skill_ids = player.skills_controller.get_unlocked_ids()

	if CheckpointManager.has_active_checkpoint():
		var entrance: Vector3 = LevelChunkManager.get_first_chunk_entrance_position()
		data.checkpoint_offset_position = CheckpointManager.get_respawn_position() - entrance

	var chunk_state: Dictionary = LevelChunkManager.get_save_data()
	data.active_chunk_paths = chunk_state.get("active_chunk_paths", [])
	data.scored_chunk_indices = chunk_state.get("scored_indices", [])
	data.chunk_selector_state = chunk_state.get("selector_state", {})

	data.collected_collectible_positions = _consumed_collectible_positions.duplicate()
	data.killed_enemy_positions = _killed_enemy_positions.duplicate()
	return data


func _apply(data: SaveData, player: PlayerEntity) -> void:
	GameEvents.score = data.score
	GameEvents.gold = data.gold
	GameEvents.score_updated.emit(data.score)
	GameEvents.gold_updated.emit(data.gold)

	player.health.current_health = maxi(data.player_health, 1)

	for id: StringName in data.unlocked_skill_ids:
		var def: SkillDefinition = SkillRegistry.get_definition(id)
		if def:
			player.skills_controller.unlock(def)

	_consumed_collectible_positions = data.collected_collectible_positions.duplicate()
	_killed_enemy_positions = data.killed_enemy_positions.duplicate()

	(
		LevelChunkManager
		. load_save_data(
			data.active_chunk_paths,
			data.scored_chunk_indices,
			data.chunk_selector_state,
		)
	)

	# Position set after chunk physics settle; also resets death movement state
	if data.checkpoint_offset_position != Vector3.ZERO:
		var entrance: Vector3 = LevelChunkManager.get_first_chunk_entrance_position()
		var restored: Vector3 = entrance + data.checkpoint_offset_position
		CheckpointManager.restore_position(restored)
		_pending_player = player
		_pending_checkpoint = restored
		_place_player_at_checkpoint.call_deferred()

	_disable_killed_enemies.call_deferred()
	_disable_consumed_collectibles.call_deferred()


func _place_player_at_checkpoint() -> void:
	if not is_instance_valid(_pending_player) or _pending_checkpoint == Vector3.ZERO:
		return
	await get_tree().process_frame
	_pending_player.global_position = _pending_checkpoint
	_pending_player.velocity = Vector3.ZERO
	_pending_player.movement_controller.movement_enabled = true
	_pending_player.movement_controller.disable_timer = 0.0
	_pending_checkpoint = Vector3.ZERO
	_pending_player = null


func _disable_consumed_collectibles() -> void:
	for pos: Vector3 in _consumed_collectible_positions:
		for c: Node in get_tree().get_nodes_in_group(Groups.COLLECTIBLES):
			var collectible: Collectible = c as Collectible
			if collectible == null:
				continue
			if pos.distance_squared_to(collectible.spawn_position) < _COLLECTIBLE_MATCH_SQ:
				c.queue_free()
				break


func _disable_killed_enemies() -> void:
	for pos: Vector3 in _killed_enemy_positions:
		for enemy: Node in get_tree().get_nodes_in_group(Groups.ENEMIES):
			var entity: AggressiveEntity = enemy as AggressiveEntity
			if entity == null:
				continue
			if pos.distance_squared_to(entity.spawn_position) < _ENEMY_MATCH_SQ:
				enemy.queue_free()
				break


# PLACEHOLDER
func _migrate(data: SaveData) -> bool:
	data.save_version = CURRENT_SAVE_VERSION
	return true


func _slot_path(slot_index: int) -> String:
	return SAVE_DIR + "slot_%d.tres" % slot_index


func _load_slot_resource(slot_index: int) -> SaveData:
	var base: String = _slot_path(slot_index)
	var data: SaveData = ResourceLoader.load(base) as SaveData
	if data != null:
		return data
	var bak: String = base + ".bak"
	if FileAccess.file_exists(bak):
		push_error("SaveManager: slot %d corrupt, loading backup" % slot_index)
		data = ResourceLoader.load(bak) as SaveData
	return data


func _safe_remove(path: String) -> bool:
	var err: int = DirAccess.remove_absolute(path)
	if err != OK:
		push_error("SaveManager: failed removing %s (%d)" % [path, err])
		return false
	return true


func _safe_rename(from: String, to: String) -> bool:
	var err: int = DirAccess.rename_absolute(from, to)
	if err != OK:
		push_error("SaveManager: failed renaming %s -> %s (%d)" % [from, to, err])
		return false
	return true


func _find_next_auto_slot() -> int:
	var oldest_index: int = 0
	var oldest_timestamp: float = INF
	for i: int in range(AUTO_SLOTS):
		var slot: int = MANUAL_SLOTS + i
		var data: SaveData = get_slot_data(slot)
		if data == null:
			return i
		if data.save_timestamp < oldest_timestamp:
			oldest_timestamp = data.save_timestamp
			oldest_index = i
	return oldest_index
