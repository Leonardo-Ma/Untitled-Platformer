## Icon row action label | clickable keyboard icon | read-only gamepad icon | per-row reset
class_name RebindingRow
extends PanelContainer

signal rebind_requested(action: StringName)
signal reset_requested(action: StringName)

var _action: StringName = &""
var _listening: bool = false
var _pulse_tween: Tween

@onready var _label: Label = %ActionLabel
@onready var _key_button: Button = %KeyButton
@onready var _gamepad_icons: HBoxContainer = %GamepadIconsContainer
@onready var _reset_button: Button = %ResetButton


func setup(action: StringName, display_name: String) -> void:
	_action = action
	_label.text = display_name
	_key_button.pressed.connect(func() -> void: rebind_requested.emit(_action))
	_reset_button.pressed.connect(func() -> void: reset_requested.emit(_action))
	GamepadIconMap.map_changed.connect(_refresh_gamepad)
	InputBindingManager.binding_changed.connect(_on_binding_changed)
	_refresh_keyboard()
	_refresh_gamepad()


func set_listening(active: bool) -> void:
	_listening = active
	_key_button.disabled = active
	_reset_button.disabled = active
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	if active:
		_pulse_tween = create_tween().set_loops()
		_pulse_tween.tween_property(_key_button, "modulate", Color(0.4, 0.8, 1.0, 1.0), 0.5)
		_pulse_tween.tween_property(_key_button, "modulate", Color.WHITE, 0.5)
	else:
		_key_button.modulate = Color.WHITE
		_refresh_keyboard()


func _on_binding_changed(action: StringName) -> void:
	if action == _action:
		_refresh_keyboard()


func _refresh_keyboard() -> void:
	var event: InputEventKey = InputBindingManager.get_keyboard_event(_action)
	if event == null:
		_key_button.icon = null
		return
	var key: Key = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
	_key_button.icon = KeyboardIconMap.get_keyboard_icon(key)


func _refresh_gamepad() -> void:
	for child: Node in _gamepad_icons.get_children():
		_gamepad_icons.remove_child(child)
		child.free()
	for event: InputEvent in InputMap.action_get_events(_action):
		var icon: Texture2D = GamepadIconMap.get_icon_for_event(event)
		if icon == null:
			continue
		var rect: TextureRect = TextureRect.new()
		rect.texture = icon
		rect.custom_minimum_size = Vector2(64, 64)
		rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_gamepad_icons.add_child(rect)
