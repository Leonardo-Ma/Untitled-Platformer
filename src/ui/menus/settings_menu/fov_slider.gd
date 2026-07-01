extends HSlider


func _ready() -> void:
	value = SettingsManager.camera_fov
	value_changed.connect(_on_value_changed)
	SettingsManager.settings_reset.connect(_on_settings_reset)


func _on_value_changed(new_value: float) -> void:
	SettingsManager.camera_fov = new_value
	SettingsManager.save()
	_apply_to_active_player(new_value)


func _on_settings_reset() -> void:
	value = SettingsManager.camera_fov


func _apply_to_active_player(fov: float) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYERS)
	assert(players.size() > 0, "Player missing to change FOV setting.")
	(players[0] as PlayerEntity).skills_controller.set_base_fov(fov)
