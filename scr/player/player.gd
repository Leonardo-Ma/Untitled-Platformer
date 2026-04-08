class_name PlayerEntity
extends AggressiveEntity

@onready var interact_ray: RayCast3D = %InteractRay
@onready var movement_controller: Node3D = %MovementController
@onready var input_controller: Node = %InputController
@onready var inventory_controller: Node = %InventoryController


func _physics_process(delta: float) -> void:
	movement_controller.move(self, delta)


func _entity_ready() -> void:
	add_to_group("players")
	GameEvents.player_spawned.emit(self)

	# Connect controllers directly to each other
	input_controller.inventory_toggled.connect(func(): inventory_controller.inventory_toggled.emit())
	input_controller.interact_requested.connect(_on_interact_requested)
	input_controller.attack_pressed.connect(_on_attack_pressed)


func _requires_goap() -> bool:
	return false


func _on_interact_requested() -> void:
	_interact()


func _on_attack_pressed() -> void:
	melee_attacked.emit()


func _interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
