@icon("res://icons/16x16/character_move.png")
extends Node3D

const JUMP_VELOCITY : float = 6.5

@export_group("Debug")
@export var walk_speed: float = 3.0
@export var run_speed: float = 5.0

@export var camera: Node3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var _movement_enabled: bool = true
var _disable_timer: float = 0.0

@onready var magic_controller: Node = $"../MagicController"

# These signals go to animation controller
signal move_started(is_running : bool)
signal move_stopped
signal movement_direction_changed(direction: Vector2, is_running: bool)
signal jumped
signal in_air
signal landed

func _ready() -> void:
	magic_controller.cast_started.connect(_on_cast_started)

func _on_cast_started(freeze_duration: float) -> void:
	disable_movement(freeze_duration)

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
		body.velocity.x = move_toward(body.velocity.x, 0, Globals.player_speed)
		body.velocity.z = move_toward(body.velocity.z, 0, Globals.player_speed)
		return
	
	var input_direction: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	if input_direction.length() > 0:
		var direction: Vector3 = (body.transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()

		var is_running: bool = Input.is_action_pressed("run")
		if is_running:
			Globals.player_speed = run_speed
		else:
			Globals.player_speed = walk_speed

		emit_signal("move_started")
		
		var normalized_input: Vector2 = input_direction.normalized()
		var speed_factor: float = Globals.player_speed / run_speed  # 0.6 for walk (3/5), 1.0 for run (5/5)
		var blend_direction: Vector2 = Vector2(normalized_input.x, -normalized_input.y) * speed_factor
		
		emit_signal("movement_direction_changed", blend_direction)

		# Make armature relative to camera instead of locking upfront
		#if direction.length() > 0.01:
			#armature.look_at(armature.global_transform.origin + direction, Vector3.UP)

		body.velocity.x = direction.x * Globals.player_speed
		body.velocity.z = direction.z * Globals.player_speed
	else:
		emit_signal("move_stopped")
		emit_signal("movement_direction_changed", Vector2.ZERO)
		body.velocity.x = move_toward(body.velocity.x, 0, Globals.player_speed)
		body.velocity.z = move_toward(body.velocity.z, 0, Globals.player_speed)

func jump_air_logic(body: CharacterBody3D, delta: float) -> void :
	if not body.is_on_floor():
		emit_signal("in_air")
		body.velocity.y -= gravity * delta
	else:
		emit_signal("landed")
		if Input.is_action_just_pressed("jump"):
			emit_signal("jumped")
			body.velocity.y = JUMP_VELOCITY

func disable_movement(duration: float) -> void:
	_movement_enabled = false
	_disable_timer = duration
