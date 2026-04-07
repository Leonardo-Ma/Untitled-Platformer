extends TextEdit

var player: PlayerEntity = null


func _ready() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	for p: Node in players:
		if p is PlayerEntity:
			player = p as PlayerEntity
			break

	GameEvents.player_spawned.connect(_on_player_spawned)

	if player != null and player.stats != null:
		player.stats.stats_changed.connect(_update_ui)

	# TODO Implement this ui toggle
	# Update only when opened
	visibility_changed.connect(_update_ui)
	_update_ui()


func _on_player_spawned(spawned_player: Node) -> void:
	# Avoid connecting multiple times if somehow spawned twice
	if player != null and player.stats != null and player.stats.stats_changed.is_connected(_update_ui):
		player.stats.stats_changed.disconnect(_update_ui)

	player = spawned_player as PlayerEntity
	if player != null and player.stats != null:
		player.stats.stats_changed.connect(_update_ui)
	_update_ui()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_attributes"):
		self.visible = not self.visible


func _update_ui() -> void:
	if not self.visible or player == null or player.stats == null:
		return

	var lines: Array[String] = ["\t\tMain Attributes:"]

	for stat_key: String in StatTypes.Type.keys():
		var enum_value: StatTypes.Type = StatTypes.Type[stat_key]
		var stat_name: String = stat_key.to_lower()
		var stat_value: float = player.stats.get_stat(enum_value)
		lines.append("%s : %.1f" % [stat_name, stat_value])

	self.text = "\n".join(lines)
