# TODO Consider transforming into a resource
class_name RedMageMemory
extends GoapMemory

const HEALTH_LOW_THRESHOLD: float = 0.3


func init(actor: Node) -> void:
	_actor = actor

	_blackboard = {
		"position": _actor.position,
		"enemy_alive": false,
		"enemy_nearby": false,
		"enemy_in_melee_range": false,
		"enemy_position": Vector3(),
		"in_combat": false,
		"low_health": false,
		"is_wandering": false
	}


func update_blackboard() -> void:
	# BUG AI always knows player's position
	# TODO Replace this with detection system (Area3D zone)?
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	if players.is_empty():
		return

	var current_player: Node = players[0]
	assert(current_player != null, "Player node in group is null.")
	assert(current_player.get("health") != null, "Target player must have a valid Health resource.")

	var enemy_pos: Vector3 = current_player.global_position
	var actor_pos: Vector3 = _actor.global_position
	var distance: float = actor_pos.distance_to(enemy_pos)

	# BUG In order for this to work it has to be same
	# target desired distance of NavigationAgent3D
	var in_melee_range: bool = distance <= 1.2
	var enemy_nearby: bool = distance < 15

	var enemy_alive: bool = current_player.get("health").get("health") > 0
	var in_combat: bool = in_melee_range and enemy_alive

	var low_health: bool = false
	if _actor.health:
		var health_percentage: float = _actor.health.health / _actor.health.max_health
		low_health = health_percentage <= HEALTH_LOW_THRESHOLD

	_blackboard["enemy_position"] = enemy_pos
	_blackboard["position"] = actor_pos
	_blackboard["enemy_in_melee_range"] = in_melee_range
	_blackboard["enemy_nearby"] = enemy_nearby
	_blackboard["enemy_alive"] = enemy_alive
	_blackboard["in_combat"] = in_combat
	_blackboard["low_health"] = low_health
