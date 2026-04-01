## This integrates the actor (NPC) with goap.
class_name GoapAgent
extends Node

const GOAL_SWITCH_DELAY: float = 0.1

var _goals: Array[GoapGoal]
var _current_goal: GoapGoal
var _current_plan: Array[GoapAction]
var _current_plan_step: int = 0

## Memory has actor and blackboard
var _goap_memory: GoapMemory

## Per-entity action planner
var _action_planner: GoapActionPlanner

var _goal_switch_cooldown: float = 0.0


# For ever frame, is current goal still highest priority?
# if not request the action planner a new plan for new highest priority
func _process(delta: float) -> void:
	_goap_memory.update_blackboard()
	_goal_switch_cooldown -= delta

	var blackboard: Dictionary = _goap_memory.get_blackboard()
	var needs_new_plan: bool = false

	# Validate current plan step
	if _current_plan != null and not _current_plan.is_empty() and _current_plan_step < _current_plan.size():
		var current_action: GoapAction = _current_plan[_current_plan_step]
		if not current_action.is_valid(blackboard):
			_current_goal = null
			_current_plan = []
			_current_plan_step = 0
			needs_new_plan = true

	var goal: GoapGoal = _get_best_goal()
	if goal == null:
		return

	if _current_goal == null or _current_plan == null or _current_plan.is_empty():
		needs_new_plan = true
	elif _goal_switch_cooldown <= 0.0 and goal.priority() > _current_goal.priority():
		needs_new_plan = true

	if needs_new_plan:
		var new_plan: Array[GoapAction] = []
		var valid_goal: GoapGoal = null

		var sorted_goals: Array = _goals.duplicate()
		sorted_goals.sort_custom(func(a: GoapGoal, b: GoapGoal) -> bool: return a.priority() > b.priority())

		for potential_goal: GoapGoal in sorted_goals:
			if potential_goal.is_valid(blackboard):
				# When searching simply for a better priority goal, don't downgrade
				if _current_goal != null and _current_plan != null and not _current_plan.is_empty() and _goal_switch_cooldown > 0.0:
					if potential_goal.priority() <= _current_goal.priority():
						continue

				var potential_plan: Array[GoapAction] = _action_planner.get_plan(potential_goal, blackboard)
				if potential_plan != null and not potential_plan.is_empty():
					new_plan = potential_plan
					valid_goal = potential_goal
					break

		if new_plan != null and not new_plan.is_empty():
			_current_goal = valid_goal
			_current_plan = new_plan
			_current_plan_step = 0
			_goal_switch_cooldown = GOAL_SWITCH_DELAY
			#print_debug("Changed goal to: " + str(_current_goal.get_custom_class_name()))
		else:
			# Keep current goal if it's still valid instead of clearing everything
			if _current_goal == null or not _current_goal.is_valid(blackboard):
				_current_goal = null
				_current_plan = []

	if _current_plan != null and not _current_plan.is_empty():
		_follow_plan(_current_plan, delta, blackboard)


func init(actor: Node, goals: Array[GoapGoal], goap_memory: GoapMemory, actions: Array[GoapAction]) -> void:
	_goap_memory = goap_memory
	_goap_memory.init(actor)
	_goals = goals

	# Create per-entity action planner
	_action_planner = GoapActionPlanner.new()
	_action_planner.set_actions(actions)

	if actions.is_empty():
		assert(false, "GoapAgent: No actions provided for agent" + actor.name)
	if goals.is_empty():
		assert(false, "GoapAgent: No goals provided for agent" + actor.name)


## Returns the highest priority goal available
func _get_best_goal() -> GoapGoal:
	var highest_priority: GoapGoal = null

	for goal: GoapGoal in _goals:
		if goal.is_valid(_goap_memory.get_blackboard()) and (highest_priority == null or goal.priority() > highest_priority.priority()):
			highest_priority = goal

	return highest_priority


## Executes the plan
## "plan" is the current list of actions, and delta is the time since last loop
##
## Every action exposes a function called perform, which will return true when
## the job is complete, so the agent can jump to the next action in the list.
func _follow_plan(plan: Array[GoapAction], delta: float, blackboard: Dictionary) -> void:
	if plan == null or plan.is_empty() or _current_plan_step >= plan.size():
		return

	var current_action: GoapAction = plan[_current_plan_step]

	if not current_action.is_valid(blackboard):
		# Action is no longer valid, force replan
		_current_goal = null
		_current_plan = []
		return

	var is_step_complete: bool = current_action.perform(_goap_memory.get_actor(), delta, blackboard)

	if is_step_complete:
		if _current_plan_step < plan.size() - 1:
			_current_plan_step += 1
		else:
			# Plan is totally complete, clear current goal to force replanning next frame
			_current_goal = null
			_current_plan = []
