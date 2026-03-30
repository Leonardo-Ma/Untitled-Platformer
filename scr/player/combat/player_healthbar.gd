# https://www.youtube.com/watch?v=f90ieBOoIYQ DashNothing - How to Make a Great Health Bar in Godot 4 | Let's Godot
extends ProgressBar

var health: float = 0.0:
	set = _set_health

var health_resource: Health

@onready var timer: Timer = $Timer
@onready var damagebar: ProgressBar = $Damagebar


func _ready() -> void:
	GameEvents.player_spawned.connect(_on_player_spawned)

	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	if not players.is_empty():
		_on_player_spawned(players[0])


func _on_player_spawned(player: Node) -> void:
	if health_resource != null:
		return

	var player_entity: AgressiveEntity = player as AgressiveEntity
	if player_entity == null or player_entity.health == null:
		return

	health_resource = player_entity.health
	health_resource.damaged.connect(_on_damaged)
	health_resource.died.connect(_on_death)

	# Initialize health bars in proper order to avoid clamping constraints
	max_value = health_resource.max_health
	damagebar.max_value = health_resource.max_health

	# Explicitly call _set_health setter or do it dynamically via self
	self.health = health_resource.health


func _set_health(new_health: float) -> void:
	var prev_health: float = health
	health = clampf(new_health, 0, max_value)
	value = health

	# Timer for damage bar animation
	if health < prev_health:
		timer.start()
	else:
		# If health increased, update damage bar immediately
		damagebar.value = health


func _on_damaged(_attack: Attack) -> void:
	self.health = health_resource.health


func _on_death() -> void:
	queue_free()


func _on_timer_timeout() -> void:
	# Animate damagebar down to match current health
	damagebar.value = health
