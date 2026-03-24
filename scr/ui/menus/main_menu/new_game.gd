extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	get_tree().paused = false

	# TODO Study this better
	# Safely access the UIManager via its static instance
	if UIManager.instance:
		print("Found UIManager, starting game...")
		UIManager.instance.on_game_started()
	else:
		printerr("CRITICAL ERROR: UIManager.instance is null! Make sure ui.gd is attached to the UI CanvasLayer.")
