extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


# TODO Study this better
func _on_pressed() -> void:
	if UIManager.instance:
		UIManager.instance.on_game_started()
	else:
		printerr("CRITICAL ERROR: UIManager.instance is null!")
