class_name GoapActionPlanner
extends Node

var _actions: Array[GoapAction] = []


## Set actions available for planning.
## This can be changed in runtime for more dynamic options.
func set_actions(actions: Array[GoapAction]) -> void:
	_actions = actions
	if _actions.is_empty():
		push_warning("GoapActionPlanner: No actions provided! Agent will not be able to plan.")


## Receives a Goal and an optional blackboard.
## Returns a list of actions to be executed.
func get_plan(goal: GoapGoal, blackboard: Dictionary) -> Array[GoapAction]:
	var desired_state: Dictionary = goal.get_desired_state().duplicate()
	if desired_state.is_empty():
		push_warning("GoapActionPlanner: Goal '%s' has no desired state!" % goal.get_custom_class_name())
		return []

	if _actions.is_empty():
		push_error("GoapActionPlanner: Cannot plan with no actions available!")
		return []

	var root: Dictionary = {"action": goal, "state": desired_state, "children": []}  # Goal is set as root node. It feels odd, but simplifies logic.

	# Build plan tree recursively
	if not _build_plans(root, blackboard.duplicate()):
		return []

	# Convert tree to flat list of possible plans and return cheapest
	var plans: Array = _transform_tree_to_array(root, blackboard)
	return _get_cheapest_plan(plans)


## Builds graph with actions. Only includes valid plans (plans that achieve the goal).
#
## Returns true if the path has a solution.
#
## This function uses recursion to build the graph. This is necessary because any
## new action added may introduce preconditions that can be satisfied by earlier actions.
#
## Note: Circular dependencies are not handled here but are simple to implement.
func _build_plans(node: Dictionary, _blackboard: Dictionary) -> bool:
	var has_followup: bool = false

	# Each node holds its own desired state
	var desired_state: Dictionary = node.state.duplicate()

	# Remove goals already satisfied by the blackboard
	for key: String in node.state.keys():
		if desired_state[key] == _blackboard.get(key):
			desired_state.erase(key)

	# If nothing left to satisfy, this branch is complete
	if desired_state.is_empty():
		return true

	for action: GoapAction in _actions:
		if not action.is_valid(_blackboard):
			continue

		var effects: Dictionary = action.get_effects()
		var remaining_state: Dictionary = desired_state.duplicate()
		var should_use_action: bool = false

		# Check if the action satisfies any part of the desired state
		for key: String in desired_state.keys():
			if remaining_state[key] == effects.get(key):
				remaining_state.erase(key)
				should_use_action = true

		if not should_use_action:
			continue

		# Add preconditions from this action to remaining state
		var preconditions: Dictionary = action.get_preconditions()
		for key: String in preconditions:
			remaining_state[key] = preconditions[key]

		var child: Dictionary = {"action": action, "state": remaining_state, "children": []}

		# If state is now satisfied or can be satisfied recursively, add child
		if remaining_state.is_empty() or _build_plans(child, _blackboard.duplicate()):
			node.children.append(child)
			has_followup = true

	return has_followup


## Transforms action graph into list of plans and calculates cost by summing action costs.
##
## Returns list of plans.
func _transform_tree_to_array(node: Dictionary, blackboard: Dictionary) -> Array:
	var plans: Array = []

	# Leaf node: single-action plan
	if node.children.is_empty():
		var leaf_actions: Array[GoapAction] = [node.action]
		return [{"actions": leaf_actions, "cost": node.action.get_cost(blackboard)}]

	# Recursively build plans from children and add current node’s action
	for child: Dictionary in node.children:
		for plan: Dictionary in _transform_tree_to_array(child, blackboard):
			if node.action.has_method("get_cost"):
				plan.actions.append(node.action)
				plan.cost += node.action.get_cost(blackboard)
			plans.append(plan)

	return plans


# TODO Revise this, maybe only rely on priority and solve tie with random?
## Compares plan costs and returns actions from the cheapest one.
func _get_cheapest_plan(plans: Array) -> Array[GoapAction]:
	if plans.is_empty():
		push_warning("GoapActionPlanner: No valid plans found!")
		return []

	var best_plan: Dictionary = plans[0]
	for plan: Dictionary in plans:
		_print_plan(plan)
		if plan.cost < best_plan.cost:
			best_plan = plan
	return best_plan.actions


## Prints plan. Used for debugging only.
func _print_plan(plan: Dictionary) -> void:
	var action_names: Array = []
	for action: Object in plan.actions:
		action_names.append(action.get_custom_class_name())
	var info: Dictionary = {"cost": plan.cost, "actions": action_names}
	print(info)
	#WorldState.console_message(info)
