# https://www.youtube.com/watch?v=EP5AYllgHy8 Godot 4.0 Third Person Controller Tutorial ( 2023 )
class_name PlayerEntity
extends AggressiveEntity

signal toggle_inventory

@export_group("Inventory")
@export var inventory_data: InventoryData

@onready var interact_ray: RayCast3D = %InteractRay

@onready var movement_controller: Node3D = %MovementController
@onready var input_controller: Node = %InputController


func _entity_ready() -> void:
	add_to_group("players")
	GameEvents.player_spawned.emit(self)

	input_controller.inventory_toggled.connect(_on_inventory_toggled)
	input_controller.interact_requested.connect(_on_interact_requested)
	input_controller.attack_pressed.connect(_on_attack_pressed)


func _requires_goap() -> bool:
	return false


func _physics_process(delta: float) -> void:
	movement_controller.move(self, delta)


func _on_inventory_toggled() -> void:
	toggle_inventory.emit()


func _on_interact_requested() -> void:
	_interact()


func _on_attack_pressed() -> void:
	melee_attacked.emit()


func _interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
