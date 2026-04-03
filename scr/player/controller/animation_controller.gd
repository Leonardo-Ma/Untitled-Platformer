#######################################
## Player animation controller
## To be attached to AnimationTree
## This acts as a signal listener for other nodes to change animation
#######################################
extends Node

@onready var player: CharacterBody3D = $".."
@onready var health: Health = player.health
@onready var movement_controller: Node3D = %MovementController
@onready var magic_controller: Node = %MagicController


func _ready() -> void:
	_validate_animation_parameters()
	assert(self, "Animation tree not defined by " + self.name)
	#movement_controller.move_stopped.connect(_on_move_stopped)
	movement_controller.movement_direction_changed.connect(_on_movement_direction_changed)
	movement_controller.jumped.connect(_on_jumped)
	movement_controller.in_air.connect(_on_in_air)
	movement_controller.landed.connect(_on_landed)
	magic_controller.casted.connect(_on_magic_casted)
	player.melee_attacked.connect(_on_melee_attack)
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_death)


# Only if multiple idle animations (Need to create new connection in tree)
#func _on_move_stopped() -> void:
#	self.set("parameters/moving/transition_request", "idle")


func _on_movement_direction_changed(direction: Vector2) -> void:
	# Update BlendSpace2D position
	# X axis: left (-1) to right (1)
	# Y axis: backward (-0.6 walk, -1.0 run) to forward (0.6 walk, 1.0 run)
	# Speed is encoded in the magnitude: walk speed = 0.6, run speed = 1.0
	self.set("parameters/movement/blend_position", direction)


func _on_jumped() -> void:
	self.set("parameters/in_air_state/transition_request", "air")
	self.set("parameters/is_jumping/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_in_air() -> void:
	self.set("parameters/in_air_state/transition_request", "air")


func _on_landed() -> void:
	self.set("parameters/in_air_state/transition_request", "ground")


func _on_melee_attack() -> void:
	self.set("parameters/attack_transition/transition_request", "melee_attack")
	self.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_magic_casted() -> void:
	self.set("parameters/attack_transition/transition_request", "magic_attack")
	self.set("parameters/attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_damaged(_attack: Attack) -> void:
	self.set("parameters/is_damaged/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_death() -> void:
	self.set("parameters/is_alive/transition_request", "dead")


func _validate_animation_parameters() -> void:
	var required_parameters: Array[String] = [
		#"parameters/moving/transition_request",
		"parameters/movement/blend_position",
		"parameters/in_air_state/transition_request",
		"parameters/is_jumping/request",
		"parameters/attack_transition/transition_request",
		"parameters/attack/request",
		"parameters/is_damaged/request",
		"parameters/is_alive/transition_request",
	]

	for param: String in required_parameters:
		assert(self.get(param) != null, "Missing animation parameter: " + param + " in " + self.name)
