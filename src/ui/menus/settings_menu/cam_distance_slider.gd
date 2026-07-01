extends HSlider


func _ready() -> void:
	value = SettingsManager.camera_distance
	value_changed.connect(_on_value_changed)
	SettingsManager.settings_reset.connect(_on_settings_reset)


func _on_value_changed(new_value: float) -> void:
	SettingsManager.camera_distance = new_value
	SettingsManager.save()
	_apply_to_active_player(new_value)


func _on_settings_reset() -> void:
	value = SettingsManager.camera_distance


func _apply_to_active_player(distance: float) -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYERS)
	assert(players.size() > 0, "Player missing to change camera distance setting.")
	var player: PlayerEntity = players[0] as PlayerEntity
	# TODO Remove hardcoded path
	var spring_arm: SpringArm3D = player.get_node("%CamRoot/SpringArm3D")
	spring_arm.spring_length = distance
