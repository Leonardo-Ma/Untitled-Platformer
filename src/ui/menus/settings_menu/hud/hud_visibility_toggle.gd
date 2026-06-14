## Toggles HUD visibility by emitting a GameEvents signal.
extends CheckButton


func _ready() -> void:
	button_pressed = GameEvents.hud_visible
	toggled.connect(_on_toggled)


func _on_toggled(pressed: bool) -> void:
	GameEvents.hud_visibility_toggled.emit(pressed)
