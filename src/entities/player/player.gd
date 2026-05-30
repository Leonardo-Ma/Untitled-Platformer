class_name PlayerEntity
extends AggressiveEntity

@export_category("Skills")
@export var startup_skill_ids: Array[StringName] = []

@onready var movement_controller: MovementController = %MovementController
@onready var input_controller: InputController = %InputController
@onready var skills_controller: SkillsController = %SkillsController


func _physics_process(delta: float) -> void:
	movement_controller.move(self, delta)
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

	input_controller.attack_pressed.connect(_on_attack_pressed)
	# TODO Also disable input controller, player can attack between death and respawn
	health.died.connect(movement_controller.disable_movement.bind(5.0))


func _on_attack_pressed() -> void:
	melee_attacked.emit()


func _requires_goap() -> bool:
	return false


func _on_death_complete() -> void:
	GameEvents.remove_score(10)
	await respawn(2.0, CheckpointManager.get_respawn_position(), true)


func respawn(delay: float, target_position: Vector3, is_death: bool = false) -> void:
	GameEvents.player_respawning.emit(delay)

	movement_controller.disable_movement(delay)
	velocity = Vector3.ZERO

	# Wait for the screen to fade in
	await get_tree().create_timer(delay / 2.0).timeout

	global_position = target_position

	if is_death:
		health.reset()
		status_manager.clear_temporary_statuses()
		scale = Vector3.ONE

	input_controller.set_process_input(true)
	input_controller.set_process_unhandled_input(true)

	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)

	hurtbox.set_deferred("monitoring", true)
	hurtbox.set_deferred("monitorable", true)
