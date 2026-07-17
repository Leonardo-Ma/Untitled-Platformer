## Data to be persistent, one resource per save slot
class_name SaveData
extends Resource

#region Save related and metadata
@export var save_version: int = 1
@export var slot_index: int = 0
@export var is_auto_save: bool = false
@export var save_timestamp: int = 0
#endregion

#region Player stats
@export var score: int = 0
@export var gold: int = 0
@export var easter_eggs_found: int = 0
@export var found_easter_egg_names: Array[StringName] = []
@export var player_health: int = 0
@export var unlocked_skill_ids: Array[StringName] = []
#endregion

#region Procedural Chunks
@export var active_chunk_paths: Array[String] = []
@export var chunk_selector_state: Dictionary = {}
## Which active chunk index the checkpoint node belongs to
@export var has_checkpoint_position: bool = false
@export var checkpoint_chunk_index: int = 0
## Offset from that chunk's EntranceTrigger in world space at save time
@export var checkpoint_local_offset: Vector3 = Vector3.ZERO
@export var scored_chunk_indices: Array[int] = []
@export var collected_collectible_positions: Array[Vector3] = []
@export var killed_enemy_positions: Array[Vector3] = []
#endregion
