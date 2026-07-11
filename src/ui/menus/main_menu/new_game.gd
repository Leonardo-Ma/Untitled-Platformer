extends TextureButton


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	GameStateManager.request_new_game()
