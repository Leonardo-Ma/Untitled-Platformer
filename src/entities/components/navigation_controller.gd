# If this is used by GOAP, it will be disabled and enabled depending on current action
# https://www.youtube.com/watch?v=-juhGgA076E DevLogLogan Godot 4 3D - AI Pathfinding/Navigation
# TODO Maybe assert instead of if != null?
class_name NavigationController
extends Node

signal movement_direction_changed(direction: Vector2, speed_factor: float)

var _disable_timer: float = 0.0

@onready var navigation_agent: NavigationAgent3D = (
	owner.get_node("NavigationAgent3D") if owner.has_node("NavigationAgent3D") else get_parent().get_node("NavigationAgent3D")
)


func _ready() -> void:
	assert(navigation_agent != null, "NavigationAgent3D is missing for Navigation node in " + owner.name)

	if not navigation_agent.velocity_computed.is_connected(_on_navigation_agent_3d_velocity_computed):
		navigation_agent.velocity_computed.connect(_on_navigation_agent_3d_velocity_computed)
	if not navigation_agent.target_reached.is_connected(_on_navigation_agent_3d_target_reached):
		navigation_agent.target_reached.connect(_on_navigation_agent_3d_target_reached)

	# Start disabled by default for GOAP to control
	set_physics_process(false)


## For actions that may disable movement such as being pushed by knockback
func disable_movement(duration: float) -> void:
	if duration > _disable_timer:
		_disable_timer = duration
	movement_direction_changed.emit(Vector2.ZERO, 0.0)


func _physics_process(delta: float) -> void:
	if _disable_timer > 0.0:
		_disable_timer -= delta
		return

	if navigation_agent.is_navigation_finished():
		stop()
		return

	var current_location: Vector3 = owner.global_position
	var next_location: Vector3 = navigation_agent.get_next_path_position()

	var direction: Vector3 = current_location.direction_to(next_location)
	direction.y = 0.0
	direction = direction.normalized()

	var new_velocity: Vector3 = direction * owner.movement.run_speed

	if direction.length_squared() > 0.001:
		var target_rotation_y: float = atan2(direction.x, direction.z)
		owner.rotation.y = lerp_angle(owner.rotation.y, target_rotation_y, 0.15)  # smooth rotation is usually better

	navigation_agent.set_velocity(new_velocity)


func update_target_location(target_location: Vector3) -> void:
	if not navigation_agent.target_position.is_equal_approx(target_location):
		navigation_agent.target_position = target_location


func stop() -> void:
	set_physics_process(false)
	if owner != null and "velocity" in owner:
		owner.velocity = Vector3.ZERO
	if navigation_agent != null:
		navigation_agent.set_velocity(Vector3.ZERO)
	movement_direction_changed.emit(Vector2.ZERO, 0.0)


# TODO Change run_speed to use a variable that is defined by goap action instead
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	if not is_physics_processing() or _disable_timer > 0.0:
		return

	if owner != null:
		owner.velocity = safe_velocity
		owner.move_and_slide()
		# NPCs using navigation typically move forward locally.
		movement_direction_changed.emit(Vector2(0, 1), 1.0)


func _on_navigation_agent_3d_target_reached() -> void:
	if owner != null and "velocity" in owner:
		owner.velocity = Vector3.ZERO
	movement_direction_changed.emit(Vector2.ZERO, 0.0)
