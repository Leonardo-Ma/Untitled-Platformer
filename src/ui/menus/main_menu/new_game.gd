extends TextureButton


func _ready() -> void:
	pressed.connect(_on_pressed)


# TODO Study this better
func _on_pressed() -> void:
	if UIManager.instance:
		UIManager.instance.on_game_started()
	else:
		assert(false, "UIManager.instance is null! Make sure ui.gd is attached to the UI CanvasLayer.")
