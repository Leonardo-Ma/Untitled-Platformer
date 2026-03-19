# https://www.youtube.com/watch?v=EP5AYllgHy8 Godot 4.0 Third Person Controller Tutorial ( 2023 )
# https://www.youtube.com/watch?v=JlgZtOFMdfc&t=611s GDQuest - 3D TUTORIAL: Make a Smooth 3D Character Controller in Godot 4
extends Node3D

signal capture_mouse_requested
signal release_mouse_requested

@onready var cam_root: Node3D = $"."
@onready var player: CharacterBody3D = $".."

@export_group("Camera")
@export_range(0.0, 1.0, 0.1) var horizontal_sensibility: float = 0.2
@export_range(0.0, 1.0, 0.1) var vertical_sensibility: float = 0.2


# Handle camera x and y movement
# TODO Confirm if this should be on _input instead of _unhandled_input or _physics_process
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape"):
		release_mouse_requested.emit()
	var player_is_using_mouse: bool = (
		event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if event.is_action_pressed("left_click"):
		capture_mouse_requested.emit()
	if player_is_using_mouse:
		# TODO Smooth the camera rotation (Maybe lerp()?)
		# Handles horizontal camera rotation
		player.rotate_y(deg_to_rad(-event.relative.x * horizontal_sensibility))
		# Handles vertical camera rotation
		cam_root.rotate_x(deg_to_rad(-event.relative.y * vertical_sensibility))
		# Limit vertical camera rotation
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(45))
