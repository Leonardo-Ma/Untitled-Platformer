# https://www.youtube.com/watch?v=EP5AYllgHy8 Godot 4.0 Third Person Controller Tutorial ( 2023 )
extends AgressiveEntity

signal toggle_inventory

@export_group("Inventory")
@export var inventory_data: InventoryData

@onready var interact_ray: RayCast3D = $InteractRay

@onready var movement_controller: Node3D = $MovementController
@onready var input_controller: Node = $InputController

# BUG If this doesn't call parent's ready, it doesn't connect signals properly
#func _ready() -> void:
#super._ready()


func _ready() -> void:
	input_controller.inventory_toggled.connect(_on_inventory_toggled)
	input_controller.interact_requested.connect(_on_interact_requested)
	input_controller.attack_pressed.connect(_on_attack_pressed)


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
