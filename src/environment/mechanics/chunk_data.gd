## Helper definition to cache chunk layout data at startup without constantly instantiating
class_name ChunkData
extends RefCounted

var scene_path: String

var entrance_transform: Transform3D

var height_shift: float = 0.0
var is_turn: bool = false
var has_checkpoint: bool = false

var requires_multi_jump: bool
var requires_dash: bool = false
var requires_teleport: bool
var requires_slow_fall: bool

var unlocks_skill: LevelChunk.Skill = LevelChunk.Skill.NONE

var difficulty_points: int = 0
var skill_points: int = 0

var score_multiplier: float = 1.0
