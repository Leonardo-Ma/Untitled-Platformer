extends GoapGoal

class_name TrackEnemy

func get_custom_class_name() -> String:
	return "TrackEnemy"

func is_valid(_blackboard: Dictionary) -> bool:
	return _blackboard.get("enemy_in_melee_range", false) == false and _blackboard.get("low_health", false) == false

func priority() -> int:
	return 9
	
func get_desired_state() -> Dictionary:
	return {
		"enemy_in_melee_range": true
	}
