extends TextureButton

const CLOSE_COLOR: Color = Color.RED


func _ready() -> void:
	modulate = CLOSE_COLOR
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://src/main.tscn")
