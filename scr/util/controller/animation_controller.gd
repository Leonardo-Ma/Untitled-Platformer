# BUG TODO Unify this with player animation controller
extends Node
#######################################
## Entity animation controller
## To be attached to AnimationTree
#######################################

#@onready var movement_controller: Node3D = $"../MovementController"
@onready var entity: CharacterBody3D = $".."
@onready var health: Health = entity.health

@onready var navigation_controller: Node = %NavigationController


func _ready() -> void:
	assert(self, "Animation tree not defined by " + owner.name)
	#assert(movement_controller, "Movement controller not defined by " + owner.name)
	assert(entity, "Entity not defined by " + owner.name)
	assert(health, "Health not defined by " + owner.name)
	navigation_controller.move_started.connect(_on_move_started)
	navigation_controller.move_stopped.connect(_on_move_stopped)
	#movement_controller.jumped.connect(_on_jumped)
	#movement_controller.in_air.connect(_on_in_air)
	#movement_controller.landed.connect(_on_landed)
	entity.melee_attacked.connect(_on_attack)
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_death)


func _on_move_started(is_running: bool = false) -> void:
	self.set("parameters/moving/transition_request", "moving")
	self.set("parameters/is_running/blend_amount", int(is_running))


func _on_move_stopped() -> void:
	self.set("parameters/moving/transition_request", "idle")


func _on_jumped() -> void:
	self.set("parameters/in_air_state/transition_request", "air")
	self.set("parameters/is_jumping/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_in_air() -> void:
	self.set("parameters/in_air_state/transition_request", "air")


func _on_landed() -> void:
	self.set("parameters/in_air_state/transition_request", "ground")


func _on_attack() -> void:
	self.set("parameters/ground_attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_damaged(_attack: Attack = null) -> void:
	self.set("parameters/is_damaged/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _on_death() -> void:
	self.set("parameters/is_alive/transition_request", "dead")
