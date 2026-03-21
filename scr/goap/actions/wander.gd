class_name WanderAction
extends GoapAction

const WANDER_RADIUS: float = 10.0
const WANDER_COOLDOWN: float = 2.0
var _wander_timer: float = 0.0
var _wander_duration: float = 5.0
var _wander_target_set: bool = false
var _wander_cooldown: float = 0.0


func get_custom_class_name() -> String:
	return "WanderAction"


func is_valid(_blackboard: Dictionary) -> bool:
	return true


func get_cost(_blackboard: Dictionary) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {}


func get_effects() -> Dictionary:
	return {"is_wandering": true}


func perform(_actor: Node, _delta: float, _blackboard: Dictionary) -> bool:
	var actor_position: Vector3 = _blackboard.get("position", _actor.global_position)

	if _wander_cooldown > 0.0:
		_wander_cooldown -= _delta
		return false

	if not _wander_target_set or _wander_timer >= _wander_duration:
		var random_offset: Vector3 = Vector3(randf_range(-WANDER_RADIUS, WANDER_RADIUS), 0, randf_range(-WANDER_RADIUS, WANDER_RADIUS))
		var wander_target: Vector3 = actor_position + random_offset

		_actor.navigation_controller.set_physics_process(true)
		_actor.navigation_controller.update_target_location(wander_target)
		_wander_target_set = true
		_wander_timer = 0.0

	_wander_timer += _delta

	if _wander_timer >= _wander_duration:
		_wander_target_set = false
		_wander_timer = 0.0
		_wander_cooldown = WANDER_COOLDOWN
		return true

	return false
