@icon("uid://bhbhlf4t28wyo")  # glow.png
## Contains unlockable flags and parameters for player abilities.
class_name PlayerSkills extends Resource

signal skill_unlocked(skill_name: String)

@export_group("Multi Jump")
@export var can_double_jump: bool = false
@export var can_triple_jump: bool = false
@export var extra_jump_velocity: float = 6.0
@export var jump_fov_increase: float = 8.0
@export var jump_fov_duration: float = 0.2

@export_group("Ground Dash")
@export var can_ground_dash: bool = false
@export var ground_dash_velocity_multiplier: float = 2.5
@export var ground_dash_duration: float = 0.4
@export var ground_dash_cooldown: float = 1.0

@export_group("Air Dash")
@export var can_air_dash: bool = false
@export var air_dash_velocity_multiplier: float = 2.5
@export var air_dash_duration: float = 0.4
@export var air_dash_cooldown: float = 1.0

@export_group("Teleport Dash")
@export var can_teleport_dash: bool = false
@export var teleport_max_charges: int = 2
@export var teleport_charge_regen_time: float = 3.0
@export var teleport_distance: float = 6.0

@export_group("Feather Fall")
@export var can_feather_fall: bool = false
@export var feather_fall_gravity_mult: float = 0.3
