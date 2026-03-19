@icon("res://icons/16x16/computer.png")
## Configuration resource for entity AI
## Defines which actions and goals are available for a specific entity type
class_name AIConfig
extends Resource

@export_category("GOAP Actions")
@export var available_actions: Array[Script] = []

@export_category("GOAP Goals")
@export var available_goals: Array[Script] = []


## Creates action instances from the configured scripts
func create_actions() -> Array[GoapAction]:
	var actions: Array[GoapAction] = []
	for action_script in available_actions:
		if action_script and action_script.can_instantiate():
			var instance: Variant = action_script.new()
			if instance is GoapAction:
				actions.append(instance)
				#print_debug("AIConfig: Loaded action '%s'" % instance.get_custom_class_name())
			else:
				push_error(
					"AIConfig: Script '%s' is not a GoapAction!" % action_script.resource_path
				)

	if actions.is_empty():
		push_error("AIConfig: No valid actions created!")
	return actions


## Creates goal instances from the configured scripts
func create_goals() -> Array[GoapGoal]:
	var goals: Array[GoapGoal] = []
	for goal_script in available_goals:
		if goal_script and goal_script.can_instantiate():
			var instance: Variant = goal_script.new()
			if instance is GoapGoal:
				goals.append(instance)
				#print_debug("AIConfig: Loaded goal '%s'" % instance.get_custom_class_name())
			else:
				push_error("AIConfig: Script '%s' is not a GoapGoal!" % goal_script.resource_path)

	if goals.is_empty():
		push_error("AIConfig: No valid goals created!")
	return goals
