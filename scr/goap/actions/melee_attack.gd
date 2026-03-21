class_name MeleeAttack
extends GoapAction

var _attack_cooldown: float = 0.7
var _elapsed: float = 0.0


func get_custom_class_name() -> String:
	return "MeleeAttack"


func is_valid(_blackboard: Dictionary) -> bool:
	return _blackboard.get("in_combat", false) == true


func get_cost(_blackboard: Dictionary) -> int:
	return 1


func get_preconditions() -> Dictionary:
	return {"enemy_in_melee_range": true, "enemy_alive": true}


func get_effects() -> Dictionary:
	return {"enemy_alive": false}


func perform(_actor: Node, _delta: float, _blackboard: Dictionary) -> bool:
	# TODO This just zeroes the velocity, need to find better way
	_actor.navigation_controller.navigation_agent.set_velocity(Vector3.ZERO)
	_elapsed += _delta

	if _elapsed >= _attack_cooldown:
		_actor.melee_attacked.emit()
		print("attacked")
		_elapsed = 0.0
		return true
	return false
