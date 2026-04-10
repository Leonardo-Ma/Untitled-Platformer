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


func _on_death() -> void:
	print_debug("Player died! Respawning at checkpoint in 5 seconds...")

	# Block inputs so player can't move or act while dead
	input_controller.set_process_input(false)
	input_controller.set_process_unhandled_input(false)
	movement_controller.disable_movement(5.0)

	# Let death animation play out and give the player a moment
	await get_tree().create_timer(5.0).timeout

	health.reset()
	status_manager.clear_temporary_statuses()

	# Teleport to recorded active checkpoint
	global_position = CheckpointManager.get_respawn_position()
	velocity = Vector3.ZERO

	# Restore inputs safely
	input_controller.set_process_input(true)
	input_controller.set_process_unhandled_input(true)


func _interact() -> void:
	if interact_ray.is_colliding():
		interact_ray.get_collider().player_interact()
