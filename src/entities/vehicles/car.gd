class_name Car
extends CharacterBody3D

signal driving_started(player: PlayerEntity)
signal driving_stopped(player: PlayerEntity)

@export_range(0.1, 1.0, 0.01, "suffix:meters") var wheel_radius: float = 0.35

@export_range(1.0, 40.0, 0.5, "suffix:m/s") var drive_speed: float = 12.0
@export_range(0.5, 10.0, 0.1, "suffix:m/s²") var acceleration: float = 6.0
@export_range(10.0, 200.0, 1.0, "suffix:deg/s") var turn_speed: float = 90.0

var is_driven: bool = false

var _driver: PlayerEntity = null
var _current_speed: float = 0.0
var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var enter_area: Area3D = %EnterArea
@onready var camera: Camera3D = %Camera3D
@onready var _visual: Node3D = %Visual

@onready var _front_left_wheel: MeshInstance3D = %FrontLeftWheel
@onready var _front_right_wheel: MeshInstance3D = %FrontRightWheel
@onready var _back_wheels: MeshInstance3D = %BackWheels


func _ready() -> void:
	assert(enter_area != null, "EnterArea missing in " + name)
	assert(camera != null, "Camera3D missing in " + name)
	assert(_visual != null, "Visual missing in " + name)

	assert(_front_left_wheel != null, "FrontLeftWheel missing in " + name)
	assert(_front_right_wheel != null, "FrontRightWheel missing in " + name)
	assert(_back_wheels != null, "BackWheels missing in " + name)

	enter_area.body_entered.connect(_on_enter_area_body_entered)
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var input_dir: float = Input.get_axis("move_backward", "move_forward")
	var turn_dir: float = Input.get_axis("move_right", "move_left")

	_current_speed = move_toward(_current_speed, input_dir * drive_speed, acceleration * delta)

	if absf(_current_speed) > 0.01:
		rotate_y(deg_to_rad(turn_dir * turn_speed * delta) * signf(_current_speed))

	var forward: Vector3 = -global_transform.basis.z
	velocity.x = forward.x * _current_speed
	velocity.z = forward.z * _current_speed

	move_and_slide()

	_spin_wheels(delta)

	var normal: Vector3 = get_floor_normal()

	forward = (forward - normal * forward.dot(normal)).normalized()

	var target_basis: Basis = Basis.looking_at(forward, normal)

	_visual.global_basis = _visual.global_basis.slerp(target_basis, 8.0 * delta)


func _spin_wheels(delta: float) -> void:
	var spin: float = (_current_speed / wheel_radius) * delta
	_front_left_wheel.rotate_x(spin)
	_front_right_wheel.rotate_x(spin)
	_back_wheels.rotate_x(spin)


#region Enter and Exit
func _on_enter_area_body_entered(body: Node3D) -> void:
	if is_driven or body is not PlayerEntity:
		return
	is_driven = true
	_driver = body as PlayerEntity
	_driver.enter_vehicle()
	camera.current = true
	set_physics_process(true)
	_play_activation_pop()
	driving_started.emit(_driver)


func exit(exit_position: Vector3) -> void:
	assert(is_driven, "Car not driven in " + name)
	set_physics_process(false)
	_current_speed = 0.0
	velocity = Vector3.ZERO
	camera.current = false

	var driver: PlayerEntity = _driver
	_driver = null
	is_driven = false

	driver.exit_vehicle(exit_position)
	driving_stopped.emit(driver)


func _play_activation_pop() -> void:
	var tween: Tween = create_tween()
	var original_scale: Vector3 = _visual.scale
	tween.tween_property(_visual, "scale", original_scale * 1.15, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(_visual, "scale", original_scale, 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
#endregion
