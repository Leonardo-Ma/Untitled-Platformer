extends Node

@onready var player_state: String
@onready var player_speed: float = 3.0
@onready var player: CharacterBody3D = (
	get_tree().get_root().get_node_or_null("/root/Main/Player") as CharacterBody3D
)
@onready var player_animation_tree: AnimationTree = (
	get_tree().get_root().get_node_or_null("/root/Main/Player/AnimationTree") as AnimationTree
)

var player_health: Health
var player_max_health: float

var player_health_regen: float
#@onready var player_mana_regen: float = player.health.mana_regen

# TODO Move and refer mana to use generic mana component like Health
#@onready var player_max_mana: float = maxf(5, Attributes.spirit * 50)
#@onready var player_mana: float = player_max_mana:
#set(new_mana):
#player_mana = clampf(new_mana, 0, player_max_mana)
#get:
#return player_mana

# TODO Either use this a global source of truth or a new GlobalInputController autoload
@onready var mouse_mode: Input


# TODO Improve this check
func _ready() -> void:
	if player == null:
		push_error("Globals: Player not found. This is expected for UI-only scenes.")
		return
	if player_animation_tree == null:
		push_error("Globals: Player animation tree not defined in globals.")
		return
	player_health = player.health
	if player_health == null:
		push_error("Globals: Player health resource not defined in globals.")
		return
	player_max_health = player_health.max_health
	player_health_regen = player_health.health_regen
