## Toggles HUD visibility
extends CheckButton


func _ready() -> void:
	button_pressed = UIManager.hud_visible
	toggled.connect(_on_toggled)


func _on_toggled(pressed: bool) -> void:
	UIManager.set_hud_visible(pressed)
