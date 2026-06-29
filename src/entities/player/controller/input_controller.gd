@icon("uid://bcle4jlufep4u")  # joystick.png
class_name InputController extends Node

signal attack_pressed
signal return_to_checkpoint_requested

const RETURN_HOLD_DURATION: float = 1.5

var _respawn_timer: Timer

@onready var camera_controller: Node3D = %CamRoot


func _ready() -> void:
	camera_controller.capture_mouse_requested.connect(_on_capture_mouse_requested)
	camera_controller.release_mouse_requested.connect(_on_release_mouse_requested)

	_respawn_timer = Timer.new()
	_respawn_timer.one_shot = true
	_respawn_timer.wait_time = RETURN_HOLD_DURATION
	_respawn_timer.timeout.connect(func() -> void: return_to_checkpoint_requested.emit())
	add_child(_respawn_timer)


func _on_capture_mouse_requested() -> void:
	if not _is_ui_interacting():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		print_debug("Mouse captured by " + name)


func _on_release_mouse_requested() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print_debug("Mouse released by " + name)


func _is_ui_interacting() -> bool:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		return false
	var viewport: Viewport = get_viewport()
	var focus_owner: Control = viewport.gui_get_focus_owner()
	if focus_owner:
		return true
	var hovered_control: Control = viewport.gui_get_hovered_control()
	return hovered_control != null


func _input(event: InputEvent) -> void:
	if _is_ui_interacting():
		return
	if event.is_action_pressed("attack"):
		attack_pressed.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("return_to_checkpoint"):
		if CheckpointManager.has_active_checkpoint():
			_respawn_timer.start()
		get_viewport().set_input_as_handled()
	elif event.is_action_released("return_to_checkpoint"):
		_respawn_timer.stop()
