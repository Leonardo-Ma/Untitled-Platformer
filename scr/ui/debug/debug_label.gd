# TODO only execute this if debug (Maybe the whole debug UI root?)
extends Label

var event_text: String = ""

var _tracked_health: Health = null
var _damage_indicator_timer: float = 0.0


#region Setup & Signals
func _ready() -> void:
	GameEvents.player_spawned.connect(_on_player_spawned)
	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYERS)
	if not players.is_empty():
		_on_player_spawned(players[0])


func _on_player_spawned(player: Node) -> void:
	if player is PlayerEntity and player.health != null:
		if _tracked_health != player.health:
			_tracked_health = player.health
			if not _tracked_health.damaged.is_connected(_on_player_damaged):
				_tracked_health.damaged.connect(_on_player_damaged)


func _on_player_damaged(_attack: Attack) -> void:
	_damage_indicator_timer = 1.0  # Display "Yes" for 1 second


#endregion


#region Process Loop
func _process(delta: float) -> void:
	if not self.visible:
		return

	if _damage_indicator_timer > 0.0:
		_damage_indicator_timer -= delta

	var text_output: String = ""
	text_output += _get_performance_text()
	text_output += _get_player_info_text()
	text_output += "\nLast Key press: " + event_text + "\n"

	self.text = text_output


#endregion


#region Profiling Data
func _get_performance_text() -> String:
	var output: String = "--- PERFORMANCE ---\n"
	output += "FPS: %s\n" % Engine.get_frames_per_second()

	var memory_mb: float = Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0
	output += "Memory: %.2f MB\n" % memory_mb

	var orphan_nodes: int = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	output += "Orphan Nodes: %d (Press F10 to print)\n" % orphan_nodes

	var draw_calls: int = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	output += "Draw Calls: %d\n\n" % draw_calls
	var objects: float = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	output += "objects: %d\n" % objects
	var physics_objects: float = Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS)
	output += "physics_objects: %d\n" % physics_objects
	var cpu_time: float = Performance.get_monitor(Performance.TIME_PROCESS) * 1000
	output += "cpu_time: %d\n" % cpu_time
	return output


#endregion


#region Player Info Data
func _get_player_info_text() -> String:
	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYERS)
	if players.is_empty() or not is_instance_valid(players[0]):
		return "--- No Player Found ---\n"

	var player_entity: PlayerEntity = players[0] as PlayerEntity
	if player_entity == null:
		return "--- Invalid Player Node ---\n"

	var output: String = "--- %s ---\n" % player_entity.name
	output += "Position: %.1v\n" % player_entity.global_position

	var is_in_air: bool = not player_entity.is_on_floor()
	output += "In Air: %s\n" % str(is_in_air)

	# Trusting domain asserts for core dependencies, simply displaying information.
	var current_speed: float = player_entity.movement_controller.current_speed
	output += "Move Speed: %.1f\n" % current_speed

	var is_running: bool = current_speed > player_entity.movement.walk_speed + 0.1
	output += "Running: %s\n" % ("Yes" if is_running else "No")

	output += "Health: %.2f / %.2f\n" % [player_entity.health.health, player_entity.health.max_health]
	output += "Invulnerable: %s\n" % ("YES" if player_entity.health.invulnerable else "NO")

	var recently_damaged: String = "Yes" if _damage_indicator_timer > 0.0 else "No"
	output += "Damaged: %s\n" % recently_damaged

	return output


#endregion


#region Input Polling
func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		event_text = event.as_text()

		# Temporary built-in debug hook to dump orphan details to Godot terminal
		if event is InputEventKey and event.keycode == KEY_F10:
			print_debug("=== DEBUG: PRINTING ORPHAN NODES ===")
			Node.print_orphan_nodes()
#endregion
