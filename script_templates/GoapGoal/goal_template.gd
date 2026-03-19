extends GoapGoal

class_name GoalName


func get_custom_class_name() -> String:
	return "GoalName"


func is_valid(_blackboard: Dictionary) -> bool:
	return true


func priority() -> int:
	return 1


func get_desired_state() -> Dictionary:
	return {"insert_desired_state": true}
