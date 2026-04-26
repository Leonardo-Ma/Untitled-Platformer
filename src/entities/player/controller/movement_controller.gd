# https://www.youtube.com/watch?v=EP5AYllgHy8 Godot 4.0 Third Person Controller Tutorial ( 2023 )
@icon("res://icons/16x16/character_move.png")
## Player movement controller
class_name MovementController extends Node3D

# These signals go to animation controller, debug...
signal movement_direction_changed(direction: Vector2, speed_factor: float)
signal jumped
signal in_air
signal landed

const COYOTE_TIME: float = 0.05

@export var camera: Node3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed: float = 0.0
var movement_enabled: bool = true
var coyote_timer: float = 0.0
var disable_timer: float = 0.0

@onready var magic_controller: Node = %MagicController


func _ready() -> void:
	magic_controller.cast_started.connect(_on_cast_started)


func _on_cast_started(freeze_duration: float) -> void:
	disable_movement(freeze_duration)


## This is executed by entity's _physics_process
func move(body: CharacterBody3D, delta: float) -> void:
	if disable_timer > 0.0:
		disable_timer -= delta
		if disable_timer <= 0.0:
			movement_enabled = true

	movement_logic(body)
	jump_air_logic(body, delta)


func movement_logic(body: CharacterBody3D) -> void:
	if not movement_enabled:
		movement_direction_changed.emit(Vector2.ZERO, 0.0)
		body.velocity.x = move_toward(body.velocity.x, 0, current_speed)
		body.velocity.z = move_toward(body.velocity.z, 0, current_speed)
		return

	var input_direction: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	if input_direction.length() > 0:
		var direction: Vector3 = (body.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()

		var is_running: bool = Input.is_action_pressed("run")
		if is_running:
			current_speed = owner.movement.run_speed
		else:
			current_speed = owner.movement.walk_speed

		var normalized_input: Vector2 = input_direction.normalized()
		var speed_factor: float = current_speed / owner.movement.run_speed  # 0.6 for walk (3/5), 1.0 for run (5/5)
		var blend_direction: Vector2 = Vector2(normalized_input.x, -normalized_input.y) * speed_factor

		movement_direction_changed.emit(blend_direction, speed_factor)

		# Make armature relative to camera instead of locking upfront
		#if direction.length() > 0.01:
		#armature.look_at(armature.global_transform.origin + direction, Vector3.UP)

		body.velocity.x = direction.x * current_speed
		body.velocity.z = direction.z * current_speed
	else:
		movement_direction_changed.emit(Vector2.ZERO, 0.0)
		body.velocity.x = move_toward(body.velocity.x, 0, current_speed)
		body.velocity.z = move_toward(body.velocity.z, 0, current_speed)


func jump_air_logic(body: CharacterBody3D, delta: float) -> void:
	if not body.is_on_floor():
		coyote_timer -= delta
		in_air.emit()
		body.velocity.y -= gravity * delta

		# Jump cutting: if jump button is released while moving upwards, cut velocity
		if Input.is_action_just_released("jump") and body.velocity.y > 0.0:
			body.velocity.y *= 0.5
	else:
		coyote_timer = COYOTE_TIME
		landed.emit()

	if not movement_enabled:
		return

	if Input.is_action_just_pressed("jump") and coyote_timer > 0.0:
		jumped.emit()
		body.velocity.y = owner.movement.jump_velocity
		# Reset timer to 0 so the player can't jump multiple times in the air
		coyote_timer = 0.0


func disable_movement(duration: float) -> void:
	movement_enabled = false
	if duration > disable_timer:
		disable_timer = duration
