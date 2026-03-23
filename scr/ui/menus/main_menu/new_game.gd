extends Button


# TODO Remove this from signal gui and do it from code only
func _on_pressed() -> void:
	var main_scene: PackedScene = load(UiManager.MAIN_SCENE_PATH)
	get_tree().change_scene_to_packed(main_scene)
