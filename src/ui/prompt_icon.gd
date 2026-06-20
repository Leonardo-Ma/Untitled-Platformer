## Displays input prompt icon for given action, reacting to device switches and rebinds via GamepadIconMap
class_name PromptIcon
extends TextureRect

@export_category("Prompt")
## Input this icon represents (&"jump", &"dash")
@export var action: StringName


func _ready() -> void:
	assert(action != &"", "PromptIcon: action not assigned in " + name)
	GamepadIconMap.map_changed.connect(_refresh)
	InputBindingManager.binding_changed.connect(_on_binding_changed)
	_refresh()


func _on_binding_changed(changed_action: StringName) -> void:
	if changed_action == action:
		_refresh()


func _refresh() -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action)
	var prefer_gamepad: bool = InputManager.is_gamepad_active()
	var resolved: Texture2D = null

	for event: InputEvent in events:
		var is_gamepad_event: bool = event is InputEventJoypadButton or event is InputEventJoypadMotion
		if is_gamepad_event == prefer_gamepad:
			resolved = GamepadIconMap.get_icon_for_event(event)
			if resolved != null:
				break

	texture = resolved
	visible = resolved != null
