class_name PlayerEntity
extends AggressiveEntity

@export_category("Skills")
@export var startup_skill_ids: Array[StringName] = []

@onready var camera_controller: CameraController = %CamRoot
@onready var movement_controller: MovementController = %MovementController
@onready var input_controller: InputController = %InputController
@onready var skills_controller: SkillsController = %SkillsController

@onready var _visual: Node3D = %Visual


func _physics_process(delta: float) -> void:
	movement_controller.move(self, delta)
	move_and_slide()

	# Apply physics collision with rigid bodies
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision3D = get_slide_collision(i)
		var collider: Object = collision.get_collider()
		if collider is RigidBody3D:
			var push_force: float = movement.speed * 0.1
			var push_dir: Vector3 = -collision.get_normal()
			push_dir.y = 0.0  # Prevent pushing into the ground or sky
			if push_dir.length_squared() > 0.001:
				collider.apply_impulse(push_dir.normalized() * push_force, collision.get_position() - collider.global_position)


func _child_ready() -> void:
	add_to_group(Groups.PLAYERS)
	GameEvents.player_spawned.emit(self)
	GameEvents.set_controlled_entity(self)

	input_controller.attack_pressed.connect(_on_attack_pressed)
	input_controller.return_to_checkpoint_requested.connect(_on_return_to_checkpoint_requested)

	health.damaged.connect(_on_damaged_vibration)
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


func _on_return_to_checkpoint_requested() -> void:
	if health.current_health <= 0:
		return
	await respawn(1.0, CheckpointManager.get_respawn_position())


func _on_damaged_vibration(_attack: Attack) -> void:
	# TODO Change the gamepad index to the actual player gamepad?
	Input.start_joy_vibration(0, 0.5, 0.5, 0.7)


# TODO BUG This is a garbage
#region Car methods
## Disable control, collision, combat while driving
func enter_vehicle() -> void:
	remove_from_group(Groups.PLAYERS)
	input_controller.set_process_input(false)
	input_controller.set_process_unhandled_input(false)
	skills_controller.set_physics_process(false)
	set_collision_layer_value(1, false)
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)
	camera_controller.set_active(false)
	set_physics_process(false)
	# shrink effect
	var tween: Tween = create_tween()
	tween.tween_property(_visual, "scale", Vector3.ONE * 0.001, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(func() -> void: visible = false)


## Restores control at exit_position
func exit_vehicle(exit_position: Vector3) -> void:
	global_position = exit_position
	velocity = Vector3.ZERO
	visible = true
	_visual.scale = Vector3.ZERO
	add_to_group(Groups.PLAYERS)
	set_collision_layer_value(1, true)
	hurtbox.set_deferred("monitoring", true)
	hurtbox.set_deferred("monitorable", true)
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	camera_controller.set_active(true)
	set_physics_process(true)
	GameEvents.set_controlled_entity(self)
	# Grow effect
	var tween: Tween = create_tween()
	tween.tween_property(_visual, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
#endregion
