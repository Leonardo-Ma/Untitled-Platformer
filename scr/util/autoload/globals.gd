extends Node

@onready var player_state: String
@onready var player_speed: float = 3.0
@onready var player: CharacterBody3D = get_tree().get_root().get_node("/root/Main/Player")
@onready var player_animation_tree: AnimationTree = get_tree().get_root().get_node("/root/Main/Player/AnimationTree")

@onready var player_health: Health = player.health
@onready var player_max_health: float = player_health.max_health

@onready var player_health_regen: float = player.health.health_regen
#@onready var player_mana_regen: float = player.health.mana_regen


# TODO Move and refer mana to use generic mana component like Health
#@onready var player_max_mana: float = maxf(5, Attributes.spirit * 50)
#@onready var player_mana: float = player_max_mana:
	#set(new_mana):
		#player_mana = clampf(new_mana, 0, player_max_mana)
	#get:
		#return player_mana

# TODO Either use this a global source of truth or a new GlobalInputController autoload
@onready var mouse_mode : Input

func _ready() -> void:
	assert(player_animation_tree, "Player animation tree not defined in globals")
	assert(player, "Player not defined in globals")
	assert(player_health, "Player health resource not defined in globals")
