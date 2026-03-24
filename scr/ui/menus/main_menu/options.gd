extends Button

const OPTIONS_SCENE_PATH: String = "uid://ca6513dw5vqcw"


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	var options_scene: PackedScene = load(OPTIONS_SCENE_PATH)
	get_tree().change_scene_to_packed(options_scene)
