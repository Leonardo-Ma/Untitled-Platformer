# https://www.youtube.com/watch?v=EP5AYllgHy8 Godot 4.0 Third Person Controller Tutorial ( 2023 )
@icon("res://icons/16x16/character_move.png")
extends Node3D

# These signals go to animation controller, debug...
signal move_started(is_running: bool)
signal move_stopped
signal movement_direction_changed(direction: Vector2, is_running: bool)
signal jumped
signal in_air
signal landed

# TODO Change this to  be a variable in core stats
const JUMP_VELOCITY: float = 6.5
const COYOTE_TIME: float = 0.05

@export var camera: Node3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed: float = 0.0
var _movement_enabled: bool = true
var _disable_timer: float = 0.0
var _coyote_timer: float = 0.0

@onready var magic_controller: Node = %MagicController


func _ready() -> void:
	magic_controller.cast_started.connect(_on_cast_started)


func _on_cast_started(freeze_duration: float) -> void:
	disable_movement(freeze_duration)


## This is executed by entity's _physics_process
func move(body: CharacterBody3D, delta: float) -> void:
	if _disable_timer > 0.0:
		_disable_timer -= delta
		if _disable_timer <= 0.0:
			_movement_enabled = true

	movement_logic(body)
	jump_air_logic(body, delta)

	body.move_and_slide()


func movement_logic(body: CharacterBody3D) -> void:
	if not _movement_enabled:
		emit_signal("move_stopped")
		emit_signal("movement_direction_changed", Vector2.ZERO)
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

		emit_signal("move_started")

		var normalized_input: Vector2 = input_direction.normalized()
		var speed_factor: float = current_speed / owner.movement.run_speed  # 0.6 for walk (3/5), 1.0 for run (5/5)
		var blend_direction: Vector2 = Vector2(normalized_input.x, -normalized_input.y) * speed_factor

		emit_signal("movement_direction_changed", blend_direction)

		# Make armature relative to camera instead of locking upfront
		#if direction.length() > 0.01:
		#armature.look_at(armature.global_transform.origin + direction, Vector3.UP)

		body.velocity.x = direction.x * current_speed
		body.velocity.z = direction.z * current_speed
	else:
		emit_signal("move_stopped")
		emit_signal("movement_direction_changed", Vector2.ZERO)
		body.velocity.x = move_toward(body.velocity.x, 0, current_speed)
		body.velocity.z = move_toward(body.velocity.z, 0, current_speed)


func jump_air_logic(body: CharacterBody3D, delta: float) -> void:
	if not body.is_on_floor():
		_coyote_timer -= delta
		emit_signal("in_air")
		body.velocity.y -= gravity * delta

		# Jump cutting: if jump button is released while moving upwards, slash velocity
		if Input.is_action_just_released("jump") and body.velocity.y > 0.0:
			body.velocity.y *= 0.5
	else:
		_coyote_timer = COYOTE_TIME
		emit_signal("landed")

	if Input.is_action_just_pressed("jump") and _coyote_timer > 0.0:
		emit_signal("jumped")
		body.velocity.y = JUMP_VELOCITY
		# Reset timer to 0 so the player can't jump multiple times in the air
		_coyote_timer = 0.0


func disable_movement(duration: float) -> void:
	_movement_enabled = false
	_disable_timer = duration
