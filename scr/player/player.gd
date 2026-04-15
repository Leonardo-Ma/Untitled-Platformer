class_name PlayerEntity
extends AggressiveEntity

@export_category("Skills")
@export var skills: PlayerSkills

@onready var interact_ray: RayCast3D = %InteractRay
@onready var movement_controller: MovementController = %MovementController
@onready var input_controller: InputController = %InputController
@onready var inventory_controller: InventoryController = %InventoryController
@onready var skills_controller: SkillsController = %SkillsController


func _physics_process(delta: float) -> void:
	movement_controller.move(self, delta)
	skills_controller.process_skills(self, delta)
	move_and_slide()


func _entity_ready() -> void:
	add_to_group("players")
	GameEvents.player_spawned.emit(self)

	# Connect controllers directly to each other
	input_controller.inventory_toggled.connect(func(): inventory_controller.inventory_toggled.emit())
	input_controller.interact_requested.connect(_on_interact_requested)
	input_controller.attack_pressed.connect(_on_attack_pressed)


func _requires_goap() -> bool:
	return false


func get_skills() -> Dictionary:
	if skills == null:
		return {}

	return {
		"multi_jump": skills.can_double_jump or skills.can_triple_jump,
		"ground_dash": skills.can_ground_dash,
		"air_dash": skills.can_air_dash,
		"teleport": skills.can_teleport_dash,
		"slow_fall": skills.can_feather_fall
	}


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
