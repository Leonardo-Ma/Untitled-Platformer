class_name PlayerCar
extends VehicleBody3D

signal driving_started(player: PlayerEntity)
signal driving_stopped(player: PlayerEntity)
signal teleported  # Back to checkpoint for example

@export_range(500.0, 8000.0, 100.0) var max_engine_force: float = 1200.0
@export_range(5.0, 100.0, 1.0) var brake_force: float = 7.0
@export_range(0.1, 1.0, 0.01) var max_steering: float = 0.1
@export_range(0.1, 5.0, 0.1) var steering_speed: float = 0.8

@export_category("Core")
@export var health: Health

var is_driven: bool = false

var _driver: PlayerEntity = null
var _steering: float = 0.0

@onready var enter_area: Area3D = %EnterArea

@onready var camera_anchor: Marker3D = %CameraAnchor
@onready var camera_pivot: Node3D = %CameraPivot
@onready var camera: Camera3D = %Camera3D

@onready var front_left_wheel: VehicleWheel3D = %FrontLeftWheel
@onready var front_right_wheel: VehicleWheel3D = %FrontRightWheel
@onready var back_left_wheel: VehicleWheel3D = %BackLeftWheel
@onready var back_right_wheel: VehicleWheel3D = %BackRightWheel


func _ready() -> void:
	assert(enter_area != null, "EnterArea missing in " + name)
	assert(camera_anchor != null, "CameraAnchor missing in " + name)
	assert(camera_pivot != null, "CameraPivot missing in " + name)
	assert(camera != null, "Camera3D missing in " + name)

	assert(front_left_wheel != null, "FrontLeftWheel missing in " + name)
	assert(front_right_wheel != null, "FrontRightWheel missing in " + name)
	assert(back_left_wheel != null, "BackLeftWheel missing in " + name)
	assert(back_right_wheel != null, "BackRightWheel missing in " + name)

	enter_area.body_entered.connect(_on_enter_area_body_entered)

	set_physics_process(false)


func _physics_process(delta: float) -> void:
	var throttle: float = Input.get_axis("move_backward", "move_forward")
	var steer: float = Input.get_axis("move_right", "move_left")

	_steering = move_toward(
		_steering,
		steer * max_steering,
		steering_speed * delta,
	)

	steering = _steering

	if absf(throttle) > 0.01:
		engine_force = throttle * max_engine_force
		brake = 0.0
	else:
		engine_force = 0.0
		brake = brake_force


func _process(_delta: float) -> void:
	camera_pivot.global_position = camera_anchor.global_position


func _on_enter_area_body_entered(body: Node3D) -> void:
	if is_driven or body is not PlayerEntity:
		return
	_driver = body as PlayerEntity
	_driver.camera_controller.set_active(false)

	is_driven = true
	_driver.enter_vehicle()

	camera.current = true
	set_physics_process(true)
	set_process(true)
	driving_started.emit(_driver)
	GameEvents.set_controlled_entity(self)
	self.add_to_group(Groups.PLAYERS)


func exit(exit_position: Vector3) -> void:
	assert(is_driven, "Car not driven in " + name)

	set_physics_process(false)
	set_process(false)

	engine_force = 0.0
	brake = brake_force
	steering = 0.0

	camera.current = false

	var driver: PlayerEntity = _driver
	_driver.camera_controller.set_active(true)
	_driver = null
	is_driven = false

	driver.exit_vehicle(exit_position)

	driving_stopped.emit(driver)
	self.remove_from_group(Groups.PLAYERS)


func respawn(delay: float, target_position: Vector3, is_death: bool = false) -> void:
	GameEvents.player_respawning.emit(delay)

	# Wait for the screen to fade in
	await get_tree().create_timer(delay / 2.0).timeout

	global_position = target_position

	rotation = Vector3.ZERO
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

	teleported.emit()

	if is_death:
		health.reset()
		scale = Vector3.ONE
