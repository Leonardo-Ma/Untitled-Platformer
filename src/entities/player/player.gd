class_name PlayerEntity
extends AggressiveEntity

@export_category("Skills")
@export var skills: PlayerSkills

@onready var movement_controller: MovementController = %MovementController
@onready var input_controller: InputController = %InputController
@onready var skills_controller: SkillsController = %SkillsController


func _physics_process(delta: float) -> void:
	movement_controller.move(self, delta)
	skills_controller.process_skills(self, delta)
	move_and_slide()

	# Apply physics collision with rigid bodies
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision3D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider is RigidBody3D:
			var push_force: float = movement.run_speed * 0.1

			var push_dir: Vector3 = -collision.get_normal()
			push_dir.y = 0.0  # Prevent pushing into the ground or sky
			if push_dir.length_squared() > 0.001:
				collider.apply_impulse(push_dir.normalized() * push_force, collision.get_position() - collider.global_position)


func _entity_ready() -> void:
	add_to_group(Groups.PLAYERS)
	GameEvents.player_spawned.emit(self)

	# Connect controllers directly to each other
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


func _on_attack_pressed() -> void:
	melee_attacked.emit()


func _on_death() -> void:
	GameEvents.remove_score(10)
	await respawn(5.0, CheckpointManager.get_respawn_position(), true)


func respawn(delay: float, target_position: Vector3, is_death: bool = false) -> void:
	GameEvents.player_respawning.emit(delay)

	input_controller.set_process_input(false)
	input_controller.set_process_unhandled_input(false)
	movement_controller.disable_movement(delay)
	velocity = Vector3.ZERO

	# Wait for the screen to fade in
	await get_tree().create_timer(delay / 2.0).timeout

	global_position = target_position

	if is_death:
		health.reset()
		status_manager.clear_temporary_statuses()

	input_controller.set_process_input(true)
	input_controller.set_process_unhandled_input(true)
