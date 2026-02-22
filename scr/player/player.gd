# https://www.youtube.com/watch?v=EP5AYllgHy8 Godot 4.0 Third Person Controller Tutorial ( 2023 )
extends AgressiveEntity

signal toggle_inventory()

@export_group("Inventory")
@export var inventory_data : InventoryData

@onready var interact_ray: RayCast3D = $InteractRay

@onready var movement_controller: Node3D = $MovementController

func _ready() -> void:
	# BUG If this doesn't call parent's ready, it doesn't connect signals properly
	super._ready()

func _physics_process(delta: float) -> void:
	interaction_handler(delta)
	movement_controller.move(self, delta)

# TODO Maybe an input controller component?
# TODO Maybe unhandled_input instead of process?
func interaction_handler(_delta : float) -> void :
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory.emit()
		
	if Input.is_action_just_pressed("interact"):
		_interact()
		
	if (Input.is_action_just_pressed("attack")):
		melee_attacked.emit()

func _interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
