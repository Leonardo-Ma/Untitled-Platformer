## Displays controller prompt icon that reacts to gamepad changes
class_name PromptIcon
extends TextureRect

@export_category("Prompt")
@export var xbox_icon: Texture2D
@export var playstation_icon: Texture2D
@export var keyboard_icon: Texture2D


func _ready() -> void:
	InputManager.device_changed.connect(_on_device_changed)
	_on_device_changed(InputManager.active_device)


func _on_device_changed(device: InputManager.Device) -> void:
	match device:
		InputManager.Device.GAMEPAD_XBOX, InputManager.Device.GAMEPAD_GENERIC:
			texture = xbox_icon
		InputManager.Device.GAMEPAD_PLAYSTATION:
			texture = playstation_icon
		InputManager.Device.KEYBOARD_MOUSE:
			texture = keyboard_icon
	if texture:
		show()
	else:
		hide()
