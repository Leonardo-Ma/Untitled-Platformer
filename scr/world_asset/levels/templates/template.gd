## Base class for all procedural level chunks.
class_name LevelChunk extends Node3D

enum Difficulty { EASY, MEDIUM, HARD }

@export_category("Difficulty")
@export var difficulty: Difficulty = Difficulty.EASY

@export_category("Skills Required")
@export var requires_multi_jump: bool = false
@export var requires_ground_dash: bool = false
@export var requires_air_dash: bool = false
@export var requires_teleport: bool = false
@export var requires_slow_fall: bool = false

@onready var exit_trigger: Area3D = %ExitTrigger


func _ready() -> void:
	assert(%ExitTrigger != null, "ExitTrigger missing in " + self.name)
	assert(%EntranceTrigger != null, "EntranceTrigger missing in " + self.name)
