# If this is used by GOAP, it will be disabled and enabled depending on current action
# https://www.youtube.com/watch?v=-juhGgA076E DevLogLogan Godot 4 3D - AI Pathfinding/Navigation
extends Node

signal move_started
signal move_stopped

@onready var navigation_agent: NavigationAgent3D = $"../NavigationAgent3D"


func _physics_process(_delta: float) -> void:
	var current_location: Vector3 = owner.global_transform.origin
	var next_location: Vector3 = navigation_agent.get_next_path_position()
	var new_velocity: Vector3 = (
		(next_location - current_location).normalized() * owner.movement.run_speed
	)

	owner.velocity = owner.velocity.move_toward(new_velocity, 0.25)
	owner.look_at(
		Vector3(next_location.x, owner.global_position.y, next_location.z), Vector3.UP, true
	)

	navigation_agent.set_velocity(new_velocity)


func update_target_location(target_location: Vector3) -> void:
	navigation_agent.target_position = target_location


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	owner.velocity = owner.velocity.move_toward(safe_velocity, 0.25)
	owner.move_and_slide()
	emit_signal("move_started", owner.movement.run_speed)


func _on_navigation_agent_3d_target_reached() -> void:
	owner.velocity = Vector3.ZERO
	move_stopped.emit()
